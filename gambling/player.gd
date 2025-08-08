extends CharacterBody3D

@onready var main_camera: Camera3D = $Camera3D
@onready var col: CollisionShape3D = $CollisionShape3D
@onready var inital_cam_offset = main_camera.position
@onready var money_label: Label = $UI/MoneyLabel


const gravity = 9.8 * 1.5

@export var base_speed = 5.0
@export var air_speed = 6.0
@export var base_accel = 10.0
@export var air_accel = 12.5
@export var sprint_speed = 1.5
@export var jump_vel = 7.5
@export var smoothing : float = 0.0002
@export var crouch_height = -0.5  
@export var crouch_speed = 10.0
var camera_rotation = Vector2(0, 0)
var can_move : bool = true
var sprint_spd

var mouse_sens = 0.003

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if Input.is_action_just_pressed("Quit"):
		get_tree().quit()
	elif Input.is_action_just_pressed("Reload"):
		get_tree().reload_current_scene()
	
	if event is InputEventMouseMotion:
		var mouse_event = event.relative * mouse_sens
		camera_look(mouse_event)

func camera_look(movement : Vector2):
	camera_rotation += movement
	camera_rotation.y = clamp(camera_rotation.y, -1.5, 1.2)

	main_camera.rotation.x = -camera_rotation.y
	rotate_y(-movement.x)

func _process(delta: float) -> void:
	if !is_on_floor():
		velocity.y -= gravity * delta

	var input_dir = Input.get_vector("Left", "Right", "Forward", "Back")
	input_dir.x *= 0.9
	var wishdir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if !can_move:
		wishdir = Vector3.ZERO
	var speed = base_speed if is_on_floor() else air_speed
	speed *= sprint_spd
	var accel = base_accel if is_on_floor() else air_accel
	air_accelerate(wishdir, speed, accel, delta)

	move_and_slide()

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("Space") and is_on_floor():
		velocity.y = jump_vel

	#if is_on_floor():
	velocity.x = velocity.x * pow(smoothing, delta);
	velocity.z = velocity.z * pow(smoothing, delta);

	if Input.is_action_pressed("Sprint"):
		sprint_spd = sprint_speed
	else:
		sprint_spd = 1

	var target_cam_y: float
	var target_col_z: float

	if Input.is_action_pressed("Crouch"):
		target_cam_y = inital_cam_offset.y + crouch_height
		target_col_z = 0.5
	else:
		target_cam_y = inital_cam_offset.y
		target_col_z = 1.0

	main_camera.position.y = lerp(main_camera.position.y, target_cam_y, crouch_speed * delta)
	col.scale.z = lerp(col.scale.z, target_col_z, crouch_speed * delta)

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
