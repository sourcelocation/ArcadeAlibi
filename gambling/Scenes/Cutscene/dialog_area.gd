extends Area3D

@export var id: int = 0
@export var requirements: Array[int] = []

var can_trigger = false
func _ready() -> void:
	can_trigger =  true

func _on_body_entered(body: Node3D) -> void:
	var ok = true
	for req in requirements:
		if "boombox-" + str(req) not in Save.config:
			ok = false
			break
	if "boombox-" + str(id) in Save.config:
		ok = false
	if body is Player and Game.gm.player.can_move and can_trigger and ok:
		Save.save("boombox-" + str(id),true)
		Game.gm.player.add_boombox(id)
