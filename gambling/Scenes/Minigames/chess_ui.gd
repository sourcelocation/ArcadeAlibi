extends Control

signal done

func _ready() -> void:
	$Chess.done.connect(func():done.emit())
