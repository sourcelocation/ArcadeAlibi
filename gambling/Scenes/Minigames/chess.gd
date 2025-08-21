extends Node2D

var selection_made = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if !selection_made:
			var mouse_pos = get_global_mouse_position()
			var tile_size = $Board.get_rect().size / 8.75
			var snapped_position = ((mouse_pos - $Board.position) / tile_size).floor() * tile_size + $Board.position + tile_size / 2
			$Selection.visible = true
			$Selection.position = snapped_position
		else:
			selection_made = false

		#selection_made = 
			
