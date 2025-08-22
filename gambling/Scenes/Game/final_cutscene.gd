extends Node3D

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_X:
			finish_cutscene()

func play_cutscene():
	$Camera3D.make_current()
	$Camera3D.current = true
	Game.gm.toggle_cutscene(true)
	$AnimationPlayer.play("play")

func finish_cutscene() -> void:
	$AnimationPlayer.stop()
	$Camera3D.clear_current(true)
	if Game.gm: Game.gm.toggle_cutscene(false)
	#Save.save("cutscene2", true)
	get_tree().queue_free()

func _on_animation_player_animation_finished(_anim_name:StringName) -> void:
	finish_cutscene()
