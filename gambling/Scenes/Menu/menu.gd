extends Control

@export var game : PackedScene

func _on_button_pressed() -> void:
	var temp = game.instantiate()
	add_child(temp)
	$UI.visible = false

func _on_button_2_pressed() -> void:
	var temp = game.instantiate()
	add_child(temp)
	$UI.visible = false

func _on_button_3_pressed() -> void:
	pass

func _on_button_4_pressed() -> void:
	Game.get_tree().queue_free()
