extends Button
class_name MightyButton

func _input(event):
	# Check for touch press event
	if event is InputEventScreenTouch and event.pressed:
		# Get the touch position
		var touch_pos = event.position
		# Check if touch is within the button's rectangle
		if _is_point_inside(touch_pos):
			# Simulate button press or trigger custom behavior
			emit_signal("button_down")
			# Optional: Call the button's default behavior
			button_pressed = true
			#print("emu touch")

	# Check for touch release event (optional)
	if event is InputEventScreenTouch and not event.pressed:
		var touch_pos = event.position
		if _is_point_inside(touch_pos):
			button_pressed = false
			emit_signal("button_up")
			emit_signal("pressed")


func _is_point_inside(point: Vector2) -> bool:
	var x: bool = point.x >= global_position.x and point.x <= global_position.x + (size.x * get_global_transform_with_canvas().get_scale().x)
	var y: bool = point.y >= global_position.y and point.y <= global_position.y + (size.y * get_global_transform_with_canvas().get_scale().y)
	return x and y
