extends Node3D

@onready var grid: GridContainer = $UI/VBoxContainer/ScrollContainer/Grid
@onready var area_3d: Area3D = $Area3D
@export var store_item : PackedScene

var store_item_id : int = 0

var store_data : Array = [
	{
		"icon_path" : "res://Resources/UI/money-ui.png",
		"item_name" : "CPU",
		"item_needed" : "3 Items Needed",
		"custom_button_text" : "$69420"
	},
	{
		"icon_path" : "res://Resources/UI/money-ui.png",
		"item_name" : "GPU",
		"item_needed" : "1 Items Needed",
		"custom_button_text" : "$6942069"
	}
]

func _ready() -> void:
	setup_store()

func _process(_delta):
	var player_inside_area = false
	for body in area_3d.get_overlapping_bodies():
		if body == Game.gm.player:
			player_inside_area = true
			break

	if not Game.gm.in_computer and player_inside_area:
		if Input.is_action_just_pressed("Select"):
			toggle_shop(true)
	elif not Game.gm.in_computer:
		toggle_shop(false)

func toggle_shop(visible: bool):
	$UI.visible = visible
	Game.gm.in_computer = visible

func setup_store():
	for data in store_data:
		var temp = store_item.instantiate()
		temp.buy_item.connect(on_buy_item)
		grid.add_child(temp)
		temp.setup(data, store_item_id)
		store_item_id += 1

func on_buy_item(id : int):
	print(store_data[id].get("item_name"))
