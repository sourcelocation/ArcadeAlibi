extends Node2D

signal done
var selection_made = false

func _ready() -> void: pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if !selection_made:
			var tile_size = $Board.get_rect().size / 8.75
			$Selection.visible = true
			$Selection.position = Vector2(randi_range(-3,3)*tile_size.x + tile_size.x/2,randi_range(-3,3)*tile_size.x + tile_size.x/2)
		else:
			selection_made = false

func done1():
	done.emit()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	done.emit()
