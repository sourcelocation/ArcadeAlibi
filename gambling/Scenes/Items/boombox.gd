extends Node3D

@export var dialog_play: int = 0
@export var dialogs: Array[AudioStream]

func _ready():
	$AudioStreamPlayer3D.stream = dialogs[dialog_play]
	$AudioStreamPlayer3D.play()


func _on_audio_stream_player_3d_finished() -> void:
	$AnimationPlayer.play("putback")
	if dialog_play == 0:
		Game.gm.nothingness_on()
