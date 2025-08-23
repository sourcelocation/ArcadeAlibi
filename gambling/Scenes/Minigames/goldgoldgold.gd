extends Control

signal done

func _ready():
	await get_tree().create_timer(7.0).timeout
	done.emit()
