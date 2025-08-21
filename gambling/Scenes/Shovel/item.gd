extends Node3D
class_name Item

func use(at): 
	if at.y > -4: return
	var a = preload("res://Scenes/particles.tscn").instantiate()
	add_child(a)
	a.global_position = at
