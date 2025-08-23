extends Area3D

@onready var coll_shape: CollisionShape3D = $CollisionShape3D
@onready var dead_tree: MeshInstance3D = $dead_tree
@onready var tree = tree_type.instantiate()
@onready var original_y = tree.position.y
@export var tree_type : PackedScene
@export var max_health = 100
@export var regrow_timer_sec = 30

var in_view = false
var in_zone = false
var health : int
var move_down = false

func _ready() -> void:
	add_child(tree)
	health = max_health

func _physics_process(delta: float) -> void:
	if  in_zone and in_view and Input.is_action_just_pressed("dig"):
		mine_tree()

	if move_down:
		tree.position.y = lerp(tree.position.y, original_y - 7.5, 0.03)
	if tree.position.y < original_y - 6:
		tree.position.y = original_y - 2.0
		tree.visible = false
		move_down = false

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
	$AudioStreamPlayer3D.play()
	if health <= 0:
		dead()
		Game.gm.player.give_item(100,randi_range(6,10))

func dead():
	dead_tree.visible = true
	move_down = true
	coll_shape.disabled = true
	await get_tree().create_timer(regrow_timer_sec).timeout
	dead_tree.visible = false
	coll_shape.disabled = false
	health = max_health
	move_down = false
	tree.position.y = original_y
	tree.visible = true
