extends Node3D
class_name GameManager

@onready var player = $Player

func _ready() -> void:
	if has_node("Cutscene1"):
		toggle_cutscene(true)


func toggle_cutscene(on: bool) -> void:
	player.can_move = not on

func _on_cutscene_finished(anim_name:StringName) -> void:
	toggle_cutscene(false)
	print("Cutscene finished: ", anim_name)

func _on_animation_player_animation_changed(old_name:StringName, new_name:StringName) -> void:
	toggle_cutscene(false)
	print("Cutscene finished: ")
