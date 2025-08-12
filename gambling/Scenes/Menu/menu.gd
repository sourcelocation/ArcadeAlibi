extends Control

@export var game_scene : PackedScene
@onready var game = game_scene.instantiate()
#@onready var option_sounds = [
	#preload("res://Scenes/Menu/nope1.mp3"),
	#preload("res://Scenes/Menu/nope2.mp3"),
	#preload("res://Scenes/Menu/nope3.mp3"),
	#preload("res://Scenes/Menu/nope4.mp3")
#]

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Quit"):
		get_tree().quit()
	elif Input.is_action_just_pressed("Reload"):
		get_tree().reload_current_scene()
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

func _on_play_pressed() -> void:
	add_child(game)
	$UI.visible = false

func _on_options_pressed() -> void:
	#if $AudioStreamPlayer != null:
		#var random_sound = option_sounds.pick_random()
		#if $AudioStreamPlayer.stream != random_sound:
			#$AudioStreamPlayer.stream = random_sound
	$AudioStreamPlayer.play()

func _on_quit_pressed() -> void:
	get_tree().quit()
