extends Node3D

func _ready() -> void:
	$Particles.emitting = true
	
	await get_tree().create_timer(1.0).timeout
	queue_free()
