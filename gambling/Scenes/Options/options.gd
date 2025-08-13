extends Control

@onready var sens_value: Label = $ColorRect/VBoxContainer/Sens/Value
@onready var window_value: Label = $ColorRect/VBoxContainer/Window/Value
@onready var volume_value: Label = $ColorRect/VBoxContainer/Volume/Value
@onready var vsync_value: Label = $"ColorRect/VBoxContainer/V-Sync/Value"

func _on_sens_slider_value_changed(value: float) -> void:
	sens_value.text = str(value)

func _on_window_item_selected(index: int) -> void:
	window_value.text = str($ColorRect/VBoxContainer/Window/OptionButton.get_item_text(index))

func _on_volume_slider_value_changed(value: float) -> void:
	volume_value.text = str(value).rstrip(".0") + "%"

func _on_vsync_item_selected(index: int) -> void:
	vsync_value.text = str($"ColorRect/VBoxContainer/V-Sync/OptionButton".get_item_text(index))
