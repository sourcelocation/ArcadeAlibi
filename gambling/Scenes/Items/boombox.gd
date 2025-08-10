extends Node3D

@export var dialog_play: int = 0
@export var dialogs: Array[AudioStream]

func _ready():
	$AudioStreamPlayer3D.stream = dialogs[dialog_play]
	$AudioStreamPlayer3D.play()
	
