extends TextureRect

signal toggle_pause

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("escape"):
		toggle_pause.emit()
