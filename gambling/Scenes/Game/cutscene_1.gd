extends Node3D

func _input(event: InputEvent) -> void:
    if visible:
        if event is InputEventKey:
            if event.pressed and event.keycode == KEY_X:
                $AnimationPlayer.stop()
                $Camera3D.clear_current(true)