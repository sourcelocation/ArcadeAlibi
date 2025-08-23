extends Control

@onready var sens_value: Label = $ColorRect/VBoxContainer/Sens/Value
@onready var window_value: Label = $ColorRect/VBoxContainer/Window/Value
@onready var volume_value: Label = $ColorRect/VBoxContainer/Volume/Value
@onready var vsync_value: Label = $"ColorRect/VBoxContainer/V-Sync/Value"

func _on_sens_slider_value_changed(value: float) -> void:
	sens_value.text = str(value)
	Game.gm.player.mouse_sensitivity = value

func _on_window_item_selected(index: int) -> void:
	window_value.text = $ColorRect/VBoxContainer/Window/OptionButton.get_item_text(index)
	# Handle window mode change here if needed
	match index:
		0: # Windowed
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		1: # Fullscreen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		2: # Exclusive Fullscreen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_volume_slider_value_changed(value: float) -> void:
	volume_value.text = str(int(value)) + "%"
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value / 100.0))

func _on_vsync_item_selected(index: int) -> void:
	vsync_value.text = $"ColorRect/VBoxContainer/V-Sync/OptionButton".get_item_text(index)
	# Handle V-Sync change here if needed
	match index:
		0: # Disabled
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		1: # Enabled
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		2: # Adaptive
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ADAPTIVE)
