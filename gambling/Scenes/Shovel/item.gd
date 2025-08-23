extends Node3D
class_name Item

var time = 0.0

func use(at): 
	if at.y > -4: return
	var a = preload("res://Scenes/particles.tscn").instantiate()
	add_child(a)
	a.global_position = at
	if time > 0.2: $AudioStreamPlayer3D.play(); time = 0.0
	
func _process(delta: float) -> void:
	#super._process(delta)
	time += delta
