extends Area3D

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		Game.gm.player.ladders.append(self)

func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		Game.gm.player.ladders.pop_back()
