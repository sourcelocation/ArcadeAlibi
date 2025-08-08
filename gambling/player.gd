extends CharacterBody3D

@onready var main_camera: Camera3D = $Camera3D

const gravity = 9.8 * 1.5

var speed = 5.0 if is_on_floor() else 6.0
var accel = 10.0 if is_on_floor() else 12.5
var camera_rotation = Vector2(0, 0)
var can_move : bool = true
var jump_vel = 7.5
var smoothing : float = 0.0003

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

	air_accelerate(wishdir, speed, accel, delta)

	move_and_slide()

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("Space") and is_on_floor():
		velocity.y = jump_vel

	#if is_on_floor():
	velocity.x = velocity.x * pow(smoothing, delta);
	velocity.z = velocity.z * pow(smoothing, delta);

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
