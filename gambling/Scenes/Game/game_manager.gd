extends Node3D
class_name GameManager

@onready var player = $Player
@onready var shop: Control = $Cutscene1/Control/Shop

var computer_visible = false
var computer_zone = false

func _ready() -> void:
	if has_node("Cutscene1"):
		toggle_cutscene(true)
	Game.gm = self

func _process(delta: float) -> void:
	if computer_visible and computer_zone:
		if Input.is_action_just_pressed("Select"):
			toggle_shop()
	else:
		shop.visible = false

func toggle_cutscene(on: bool) -> void:
	player.can_move = not on 

func _on__screen_entered_computer() -> void:
	computer_visible = true

func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	computer_visible = false

# Computer area
func _on_area_3d_body_entered(body: Node3D) -> void:
	computer_zone = true

func _on_area_3d_body_exited(body: Node3D) -> void:
	computer_zone = false

func toggle_shop():
	#Shop Cutscene Here like sitting down or smth.
	shop.visible = !shop.visible
	if shop.visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	player.can_move = !player.can_move
	player.velocity = Vector3.ZERO
