extends AudioStreamPlayer3D

func _ready():
	volume_db = -80

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		volume_db = -20


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is Player:
		volume_db = -80
