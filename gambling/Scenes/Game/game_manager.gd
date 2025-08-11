extends Node3D
class_name GameManager

@onready var player: Player = $Player
@onready var terrain: VoxelTerrain = $Terrain
@onready var shop: Node3D = $Shop
@onready var nothingness: MeshInstance3D = $Nothingness
@onready var money_label: Label = $UI/MoneyLabel
@export var chest : PackedScene

var computer_visible = false
var in_computer = false
var in_cutscene = false
@export var num_chests = 10.0
@export var layer_height : float = 10.0
@export var spawn_radius : float = 25.0
var layer_to_gen = 1

func _ready() -> void:
	if has_node("Cutscene1"):
		toggle_cutscene(true)
	Game.gm = self
	nothingness.visible = false

	#if "pickup_shovel" in Save.config:
		#$ShovelArea.queue_free()

func _process(delta: float) -> void:
	player.can_move = not in_computer and not in_cutscene

	if player.global_position.y <= -layer_height * (layer_to_gen - 2):
		gen_chests(layer_to_gen)
		layer_to_gen += 1

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

func gen_chests(layer : int):
	randomize()
	for i in range(num_chests + layer * 10):
		var rand_y = randf_range(-layer_height * layer, -layer_height * layer - layer_height)
		var rand_x = randf_range(-spawn_radius, spawn_radius)
		var rand_z = randf_range(-spawn_radius, spawn_radius)
		var temp = chest.instantiate()
		temp.position = Vector3(rand_x, rand_y, rand_z)
		add_child(temp)
