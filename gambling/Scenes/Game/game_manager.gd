extends Node3D
class_name GameManager

@onready var player: Player = $Player
@export var items: Array[ItemRes]

@export var layers: Array[VoxelTerrain]
@onready var terrain = layers[0]
@onready var shop: Node3D = $Shop
@onready var nothingness: MeshInstance3D = $Nothingness
@onready var money_label: Label = $UI/MoneyLabel
@export var chest : PackedScene
@export var chests_per_layer: Array[int] = [80,50]

var computer_visible = false
var in_computer = false
var in_cutscene = false
@export var layer_height : float = 10.0
@export var spawn_radius : float = 25.0
var layer_to_gen = 0

# dialog triggers
var time_underground = 0.0
@onready var chest_opened_once = "chest_opened_once" in Save.config

func _ready() -> void:
	
	
	if has_node("Cutscene1"):
		toggle_cutscene(true)
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
	if "save-data" in Save.config:
		_load_data()
		
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
	for i in range(chests_per_layer[layer]):
		var rand_y = randf_range(-layer_height * layer, -layer_height * layer - layer_height - 4.6)
		var rand_x = randf_range(-spawn_radius, spawn_radius)
		var rand_z = randf_range(-spawn_radius, spawn_radius)
		var temp = chest.instantiate()
		temp.position = Vector3(rand_x, rand_y, rand_z)
		add_child(temp)

func on_chest_opened():
	Save.save("chest_opened_once", true)
	chest_opened_once = true
	
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
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
