extends Area3D

@export var id: int = 0
@export var requirements: Array[int] = []

func _ready() -> void: pass

func _on_body_entered(body: Node3D) -> void:
	

	Game.gm.player.add_boombox(id)
