extends Panel
signal crafted(item)
var item
@onready var craft_button: Button = %CraftButton
@onready var label: Label = %Label
@onready var texture_rect: TextureRect = %TextureRect

func set_data(_item: ItemRes):
	item = _item
	texture_rect.texture = item.icon
	label.text = item.title
	for k in item.recipe.keys():
		var a = preload("res://Scenes/item_craft.tscn").instantiate()
		$Deps.add_child(a)
		a.set_data(get_item_by_id(k),item.recipe[k]-1)
		
	update_button()
	%CraftButton.pressed.connect(func():crafted.emit(item))
	
func update_button():
	var inventory = Game.gm.player.inventory
	var can_craft = true
	for recipe_item_id in item.recipe:
		if inventory.get(recipe_item_id, 0) < item.recipe[recipe_item_id]:
			can_craft = false
			break
	
	craft_button.disabled = not can_craft
	
func get_item_by_id(id):
	var item
	for _item in Game.gm.items:
		if _item.id == id:
			item = _item
	return item
