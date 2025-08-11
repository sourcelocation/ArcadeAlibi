extends Area3D

@onready var coll_shape: CollisionShape3D = $CollisionShape3D
@onready var dead_tree: MeshInstance3D = $dead_tree
@onready var tree = tree_type.instantiate()
@export var tree_type : PackedScene
@export var max_health = 100
@export var regrow_timer_sec = 30

var in_view = false
var in_zone = false
var health : int

func _ready() -> void:
	add_child(tree)
	health = max_health

func _physics_process(delta: float) -> void:
	if  in_zone and in_view and Input.is_action_just_pressed("dig"):
		mine_tree()

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		in_zone = true

func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		in_zone = false

func _on_visible_on_screen_notifier_3d_screen_entered() -> void:
	in_view = true

func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	in_view = false

func mine_tree():
	health -= 25
	if health <= 0:
		dead()
	Game.gm.player.wood += 1

func dead():
	dead_tree.visible = true
	tree.visible = false
	coll_shape.disabled = true
	await get_tree().create_timer(regrow_timer_sec).timeout
	dead_tree.visible = false
	tree.visible = true
	coll_shape.disabled = false
	health = max_health
