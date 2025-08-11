extends Node3D
class_name GameManager

@onready var player: Player = $Player
@onready var terrain: VoxelTerrain = $Terrain
@onready var shop: Node3D = $Shop
@onready var nothingness: MeshInstance3D = $Nothingness
@onready var money_label: Label = $UI/MoneyLabel
@export var chest : PackedScene

var chest_spawned_positions : Array = []
var computer_visible = false
var in_computer = false
var in_cutscene = false
var num_chests = 200.0

func _ready() -> void:
	if has_node("Cutscene1"):
		toggle_cutscene(true)
	Game.gm = self
	nothingness.visible = false
	
	#if "pickup_shovel" in Save.config:
		#$ShovelArea.queue_free()

	randomize()
	for i in range(num_chests):
		var temp = chest.instantiate()
		var rand_y = randf_range(-10, -20)
		temp.position = Vector3(randf_range(-25, 25), rand_y, randf_range(-25, 25))
		add_child(temp)

func _process(delta: float) -> void:
	player.can_move = not in_computer and not in_cutscene

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
		player.give_item(0,1)
		Save.save("pickup_shovel",true)
		$ShovelArea.queue_free()
		player.add_boombox(1)
