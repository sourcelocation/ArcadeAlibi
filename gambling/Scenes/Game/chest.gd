extends Area3D

var in_view = false
var in_zone = false

func _physics_process(delta: float) -> void:
	if  in_zone and in_view and Input.is_action_just_pressed("Select"):
		open()

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

func open():
	queue_free()
	Game.gm.player.money += randi_range(250 * (Game.gm.layer_to_gen - 3), 250 * (Game.gm.layer_to_gen - 2))
	print(Game.gm.player.money)
