extends Node3D

@onready var sub_viewport: SubViewport = $SubViewport
@onready var screen: MeshInstance3D = $MeshInstance3D2

@export var games: Array[PackedScene] = []
@export var id := 0

var game
var in_zone = false
var in_view = false
var on = false

func _ready() -> void:
	if id >= games.size():
		id = 0
	game = games[id].instantiate()
	sub_viewport.add_child(game)
	sub_viewport.process_mode = SubViewport.PROCESS_MODE_DISABLED  # start disabled
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS  # ensure it updates
	sub_viewport.size = Vector2(2560, 1440) # match your Pac-Man "virtual screen"


func _physics_process(delta: float) -> void:
	if in_zone and in_view and Input.is_action_just_pressed("Select"):
		on = !on  # toggle
		if on:
			Game.gm.player.in_arcade = true
			sub_viewport.process_mode = SubViewport.PROCESS_MODE_ALWAYS
			print("Game started")
		else:
			Game.gm.player.in_arcade = false
			sub_viewport.process_mode = SubViewport.PROCESS_MODE_DISABLED
			print("Game stopped")

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		in_zone = true

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is Player:
		in_zone = false

func _on_visible_on_screen_notifier_3d_screen_entered() -> void:
	in_view = true

func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	in_view = false
