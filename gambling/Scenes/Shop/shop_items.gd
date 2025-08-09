extends PanelContainer

signal buy_item(id)

@onready var texture_rect: TextureRect = $HBoxContainer/MarginContainer/TextureRect
@onready var item_name: Label = $HBoxContainer/MarginContainer2/VBoxContainer/Label
@onready var item_needed: Label = $HBoxContainer/MarginContainer2/VBoxContainer/Label2
@onready var button: Button = $HBoxContainer/MarginContainer2/VBoxContainer/Button

var id : int

func setup(data : Dictionary, p_id : int):
	texture_rect.texture = load(data.get("icon_path"))
	item_name.text = data.get("item_name", "")
	item_needed.text = data.get("item_needed", "")
	id = p_id

	if data.get("custom_button_text"):
		button.text = data.get("custom_button_text")

func _on_button_pressed() -> void:
	emit_signal("buy_item", id)
