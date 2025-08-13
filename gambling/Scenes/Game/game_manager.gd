extends Node3D
class_name GameManager

@onready var player: Player = $Player
@export var items: Array[ItemRes]
@onready var shop_sprite_3d: Sprite3D = $Shop/ShopSprite3D

@onready var pause_menu: TextureRect = $PauseMenu
@onready var options: Control = $Options

@onready var layers: Array[VoxelTerrain] = [$Layer1,$Layer2]
@onready var terrain = layers[0]
@onready var shop: Node3D = $Shop
@onready var nothingness: MeshInstance3D = $Nothingness
@onready var money_label: Label = $UI/MoneyLabel
@onready var shop_viewport: SubViewport = $UI/ShopViewport
@export var chest : PackedScene
@export var chests_per_layer: Array[int] = [80,50]

var computer_visible = false
var in_computer = false
var in_cutscene = false
@export var layer_height : float = 10.0
@export var spawn_radius : float = 25.0
var layer_to_gen = 0
var paused = false

# dialog triggers
var time_underground = 0.0
@onready var chest_opened_once = "chest_opened_once" in Save.config

func _ready() -> void:
	Game.gm = self
	nothingness.visible = false

	if "pickup_shovel" in Save.config:
		$ShovelArea.queue_free()

	#gen_chests(0)
	#randomize()
	#for i in range(num_chests):
		#var temp = chest.instantiate()
		#var rand_y = randf_range(-10, -20)
		#temp.position = Vector3(randf_range(-25, 25), rand_y, randf_range(-25, 25))
		#add_child(temp)
		
	player = preload("res://Scenes/Player/player.tscn").instantiate()
	if "save-data" in Save.config:
		_load_data()
	player.position = Vector3(0,1,-6)
	add_child(player)
	
	if has_node("Cutscene1"):
		if "cutscene1" not in Save.config:
			$Cutscene1/Camera3D.make_current()
			$Cutscene1/Camera3D.current = true
			toggle_cutscene(true)
			$Cutscene1/AnimationPlayer.play("play")
		else:
			$Cutscene1.queue_free()
		
@onready var dir_light_anim: AnimationPlayer = $DirectionalLight3D/AnimationPlayer
@onready var dir_light: DirectionalLight3D = $DirectionalLight3D

func _process(delta: float) -> void:
	player.can_move = not in_computer and not in_cutscene
	
	if player.position.y < -4.6 and dir_light.light_energy == 1:
		dir_light_anim.play("off")
	if player.position.y > -4.6 and dir_light.light_energy == 0:
		dir_light_anim.play("on")
		
	if player.position.y < -4.6:
		time_underground += delta
		
	if time_underground > 33.0 and not chest_opened_once and time_underground < 33.1:
		#if not player.boombox:
		player.add_boombox(2)
		
	if time_underground > 50.0 and not chest_opened_once and time_underground < 50.1:
		#if not player.boombox:
		player.add_boombox(3)

	if player.global_position.y + 5.0 <= -layer_height * layer_to_gen:
		gen_chests(layer_to_gen)
		layer_to_gen += 1

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var from = player.main_camera.project_ray_origin(event.position)
		var to = from + player.main_camera.project_ray_normal(event.position) * 1000
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(from, to)
		var result = space_state.intersect_ray(query)

		if result and result.collider.get_parent() == shop_sprite_3d:
			var local_hit = result.collider.to_local(result.position)
			
			var shape = result.collider.get_node("CollisionShape3D").shape
			var w = shape.size.x
			var h = shape.size.y
			
			var norm_x = (local_hit.x + (w / 2)) / w
			var norm_y = 1 - ((local_hit.y + (h / 2)) / h) # Invert Y for viewport coords
	  
			var viewport_pos = Vector2(norm_x, norm_y)
			viewport_pos.x *= shop_viewport.size.x
			viewport_pos.y *= shop_viewport.size.y
			var input_event = InputEventMouseButton.new()
			input_event.button_index = MOUSE_BUTTON_LEFT
			input_event.pressed = true
			input_event.position = viewport_pos
			shop_viewport.push_input(input_event)

func toggle_cutscene(on: bool) -> void:
	in_cutscene = on

	if !on:
		$UI/AnimationPlayer.stop()
		$UI/AnimationPlayer.play("show")
		print("Cutscene ended")

func nothingness_on():
	nothingness.visible = true
	player.position = nothingness.position + Vector3(0,1,0)

func _on__screen_entered_computer() -> void:
	computer_visible = true

func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	computer_visible = false

func _on_shovel_entered(body: Node3D) -> void:
	if body is Player:
		player.give_item(1,1)
		Save.save("pickup_shovel",true)
		$ShovelArea.queue_free()
		player.add_boombox(1)

func gen_chests(layer : int):
	if len(chests_per_layer) <= layer: return
	for i in range(chests_per_layer[layer]):
		var rand_y = randf_range(-layer_height * layer - 4.6, -layer_height * layer - layer_height - 4.6)
		var rand_x = randf_range(-spawn_radius, spawn_radius)
		var rand_z = randf_range(-spawn_radius, spawn_radius)
		var temp = chest.instantiate()
		temp.position = Vector3(rand_x, rand_y, rand_z)
		temp.layer = layer
		add_child(temp)

func on_chest_opened():
	if "chest_opened_once" not in Save.config:
		player.add_boombox(4)
	Save.save("chest_opened_once", true)
	chest_opened_once = true
	
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save()
	
func save():
	print("saving")
	var data = {
		"inventory": player.inventory,
		"money": player.money
	}
	Save.save("save-data", data)

func _load_data():
	var data = Save.config["save-data"]

	if data:
		player.inventory = data["inventory"]
		player.money = data["money"]

func _toggle_pause(on : bool):
	paused = on
	pause_menu.visible = on
	$Player/Control.visible = !on
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if on else Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = on

func _is_paused():
	return pause_menu.visible

func _on_resume_pressed() -> void:
	if not pause_menu.visible: return
	_toggle_pause(false)

func _on_options_pressed() -> void:
	if not pause_menu.visible: return
	options.visible = true
	pause_menu.visible = false

func _on_quit_pressed() -> void:
	if not pause_menu.visible: return
	get_tree().paused = false
	get_tree().quit()

func _on_pause_menu_toggle_pause() -> void:
	if options.visible:
		options.visible = false
		_toggle_pause(_is_paused())
	else:
		_toggle_pause(!_is_paused())
