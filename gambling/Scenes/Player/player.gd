extends CharacterBody3D
class_name Player

@onready var main_camera: Camera3D = $Camera3D
@onready var col: CollisionShape3D = $CollisionShape3D
@onready var initial_cam_offset = main_camera.position
@onready var hand: Node3D = $Camera3D/Hand
@onready var grid_container: GridContainer = %GridContainer
@onready var inventory_panel: Panel = $Control/InventoryPanel
@onready var spot_light_3d: SpotLight3D = $Camera3D/SpotLight3D

const gravity = 9.8 * 1.5
const computer_pos = Vector3(-2.156458, 1.465301, -4.937538)
const computer_rotation = Vector3(-0.03, PI, 0)

@export var base_speed = 5.0
@export var air_speed = 6.0
@export var base_accel = 10.0
@export var air_accel = 12.5
@export var sprint_speed = 1.5
@export var jump_vel = 7.5
@export var smoothing : float = 0.0002
@export var crouch_height = -0.5  
@export var crouch_speed = 10.0

@export_group("Items")
var camera_rotation = Vector2(0, 0)
var can_move : bool = true
var sprint_spd
#@onready var sub_camera: Camera3D = $CanvasLayer/SubViewportContainer/SubViewport/SubCamera
@onready var initial_cam_rotation : Vector3 = main_camera.rotation
var enter_shop = false
var leave_shop = false
var ladders : Array
var on_ladder = false
var can_ladder = true
var money = 100
var in_arcade = false

var mouse_sens = 0.003

var inventory: Dictionary
var selected_tool

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	update_items_ui()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse_event = event.relative * mouse_sens
		camera_look(mouse_event)
		


func camera_look(movement : Vector2):
	if not can_move:
		return
	camera_rotation += movement
	camera_rotation.y = clamp(camera_rotation.y, -1.5, 1.5)

	main_camera.rotation.x = -camera_rotation.y
	rotate_y(-movement.x)

func _process(delta: float) -> void:
	if !is_on_floor() and !on_ladder:
		velocity.y -= gravity * delta

	var input_dir = Input.get_vector("Left", "Right", "Forward", "Back")
	input_dir.x *= 0.9
	var wishdir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if !can_move or on_ladder:
		wishdir = Vector3.ZERO

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if !enter_shop and !Game.gm.paused else Input.MOUSE_MODE_VISIBLE)
	var speed = base_speed if is_on_floor() else air_speed
	speed *= sprint_spd
	var accel = base_accel if is_on_floor() else air_accel
	air_accelerate(wishdir, speed, accel, delta)

	Game.gm.money_label.text = "$" + str(money)

	move_and_slide()

	process_dig()
	
	process_inventory_select()
	inventory_panel.visible = Input.is_action_pressed("inventory")
	
	spot_light_3d.light_energy = 1 if position.y < -4.6 else 0
	
	main_camera.fov = lerpf(main_camera.fov, 40 if Game.gm.in_computer else 90, 0.1)
		
func process_inventory_select():
	if Input.is_action_just_pressed("select_1"):
		equip_item_slot(0)
	elif Input.is_action_just_pressed("select_2"):
		equip_item_slot(1)
	elif Input.is_action_just_pressed("select_3"):
		equip_item_slot(2)

func process_dig():
	if Input.is_action_pressed("dig") and (selected_tool == 1 or selected_tool == 2):  # e.g., hold a button to dig
		var params = PhysicsRayQueryParameters3D.new()
		params.from = main_camera.global_position
		params.to = params.from - main_camera.global_transform.basis.z * 1.75
		var result = get_world_3d().direct_space_state.intersect_ray(params) 
		if result:
			var pos = result.position
			# Process the digging logic here
			var _tool = Game.gm.terrain.get_voxel_tool()
			_tool.mode = VoxelTool.MODE_REMOVE
			_tool.do_sphere(pos,0.8 if selected_tool == 1 else 1.5)
			hand.get_child(0).use(pos)
		# Move player into the dug space if needed

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("Space") and (is_on_floor() or on_ladder):
		velocity.y = jump_vel

	if is_on_floor():
		can_ladder = true
	velocity.x = velocity.x * pow(smoothing, delta);
	velocity.z = velocity.z * pow(smoothing, delta);

	if Input.is_action_pressed("Sprint"):
		sprint_spd = sprint_speed
	else:
		sprint_spd = 1

	var target_cam_y: float
	var target_col_z: float

	if Input.is_action_pressed("Crouch") and is_on_floor():
		target_cam_y = initial_cam_offset.y + crouch_height
		target_col_z = 0.5
	else:
		target_cam_y = initial_cam_offset.y
		target_col_z = 1.0

	col.scale.z = lerp(col.scale.z, target_col_z, crouch_speed * delta)

	if enter_shop:
		main_camera.global_position = lerp(main_camera.global_position, computer_pos, 0.05)
		main_camera.rotation.x = lerp_angle(main_camera.rotation.x, computer_rotation.x - global_rotation.x, 0.05)
		main_camera.rotation.y = lerp_angle(main_camera.rotation.y, computer_rotation.y - global_rotation.y, 0.05)
		main_camera.rotation.z = lerp_angle(main_camera.rotation.z, computer_rotation.z - global_rotation.z, 0.05)
	else:
		main_camera.position.y = lerp(main_camera.position.y, target_cam_y, crouch_speed * delta)
	if !ladders.is_empty() and can_ladder:
		if Input.is_action_just_pressed("Space"):
			can_ladder = false
			on_ladder = false
		else:
			on_ladder = true
			can_move = false
			velocity = Vector3.ZERO

			var ladder_speed = 400.0
			if Input.is_action_pressed("Forward"):
				velocity += ladders[0].global_transform.basis.z * ladder_speed * delta
			elif Input.is_action_pressed("Back"):
				velocity += ladders[0].global_transform.basis.z * -ladder_speed * delta
	else:
		on_ladder = false
		can_move = true

func air_accelerate(wishdir : Vector3, wishspeed : float, accele : float, delta : float):
	var addspeed : float
	var accelspeed : float
	var current_speed : float

	current_speed = velocity.dot(wishdir)
	addspeed = wishspeed - current_speed
	if addspeed <= 0:
		return

	accelspeed = accele * wishspeed * delta
	if accelspeed > addspeed:
		accelspeed = addspeed

	velocity += accelspeed * wishdir


var boombox: Node3D
func add_boombox(id: int):
	if boombox:
		boombox.queue_free()
	boombox = preload("res://Scenes/Items/boombox.tscn").instantiate()
	boombox.dialog_play = id
	hand.add_child(boombox)

func on_shop_toggle(on):
	if on:
		enter_shop = true
		can_move = false
	else:
		main_camera.position.x = 0
		main_camera.position.z = 0
		main_camera.rotation.z = 0
		main_camera.rotation.y = 0
		main_camera.rotation.x = 0
		enter_shop = false
		leave_shop = true
		can_move = true
	Game.gm.shop_ui._update()

func update_items_ui():
	var container = $Control/ItemsContainer
	for c in container.get_children(): c.queue_free()
	for c in grid_container.get_children(): c.queue_free()
	
	var i = 0
	for item in get_tools_in_inventory():
		var n = preload("res://Scenes/item_ui.tscn").instantiate()
		n.set_data(item, i)
		container.add_child(n)
		i += 1
		
	var keys = inventory.keys()
	keys.sort()
	for item in keys:
		if inventory[item] == 0: continue
		var n = preload("res://Scenes/item_ui.tscn").instantiate()
		n.set_data(get_item_by_id(item), inventory[item] - 1)
		grid_container.add_child(n)

func give_item(id, count):
	if id in inventory: 
		inventory[id] += count
	else:
		inventory[id] = count
		
	if id < 100:
		equip_item(get_item_by_id(id))
	update_items_ui()
		
func get_item_by_id(id):
	var item
	for _item in Game.gm.items:
		if _item.id == id:
			item = _item
	return item
	

func equip_item(_item):
	for c in hand.get_children(): if c != boombox: c.queue_free()
	if _item != null:
		var item = _item.scene.instantiate()
		hand.add_child(item)
		selected_tool = _item.id
		
	if _item and _item.id >= 200 and _item.id < 300:
		for c in get_tree().get_nodes_in_group("arcade"): c.toggle(true)
		for c in get_tree().get_nodes_in_group("casino"): c.toggle(false)
	elif _item and _item.id >= 300 and _item.id < 400:
		for c in get_tree().get_nodes_in_group("casino"): c.toggle(true)
		for c in get_tree().get_nodes_in_group("arcade"): c.toggle(false)
	else:
		for c in get_tree().get_nodes_in_group("casino"): c.toggle(false)
		for c in get_tree().get_nodes_in_group("arcade"): c.toggle(false)
func get_tools_in_inventory():
	var tools = []
	var keys = inventory.keys()
	keys.sort()
	for id in keys:
		var tool = get_item_by_id(id)
		if tool.is_tool:
			if inventory[id] <= 0: continue
			tools.append(tool)
	return tools

func equip_item_slot(i):
	var tools = get_tools_in_inventory()
	if i < tools.size():
		equip_item(tools[i])
