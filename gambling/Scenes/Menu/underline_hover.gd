extends Control

@onready var ap = $Label/ColorRect/AnimationPlayer

func _on_mouse_entered() -> void:
	ap.play("show")


func _on_mouse_exited() -> void:
	ap.play("hide")
	
