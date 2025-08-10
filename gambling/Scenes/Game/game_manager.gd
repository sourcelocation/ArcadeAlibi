extends Node3D
class_name GameManager

@onready var player = $Player
@onready var terrain: VoxelTerrain = $Terrain
@onready var shop: Node3D = $Shop

var computer_visible = false
var in_computer = false
var in_cutscene = false

func _ready() -> void:
	if has_node("Cutscene1"):
		toggle_cutscene(true)
	Game.gm = self

	shop.shop_toggle.connect(player.on_shop_toggle)

func _process(delta: float) -> void:
	player.can_move = not in_computer and not in_cutscene

func toggle_cutscene(on: bool) -> void:
	in_cutscene = on

	if !on:
		$UI/AnimationPlayer.stop()
		$UI/AnimationPlayer.play("show")
		print("Cutscene ended")

func _on__screen_entered_computer() -> void:
	computer_visible = true

func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	computer_visible = false
