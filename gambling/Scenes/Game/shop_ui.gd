extends Control

@onready var items = preload("res://Globals/items.tres").items
@onready var items_container_craft: VBoxContainer = %ItemsContainerCraft
@onready var scene = preload("res://Scenes/item_row_craft.tscn")
@onready var shovel: Button = %shovel
@onready var cure: Button = %cure
@onready var back: Button = %back
@onready var moneydeposit: Label = $TabContainer/Deposit/moneydeposit

func _ready():
	shovel.disabled = "shovel-bought" in Save.config
	if "shovel-bought" in Save.config:
		shovel.text = "PURCHASED"
	#cure.disabled = "cure-bought" in Save.config
	if "cure-bought" in Save.config:
		cure.text = "PURCHASED"
	back.disabled = "back-bought" in Save.config
	if "back-bought" in Save.config:
		back.text = "PURCHASED"
	await get_tree().create_timer(0.05).timeout
	_update()
	
	$TabContainer/Crafting.visible = true
	
func _process(delta: float) -> void:
	moneydeposit.text = "$" + str(Game.gm.player.money)
	
func _update():
	for c in items_container_craft.get_children(): c.queue_free()
	for item in items:
		if len(item.recipe.keys()) == 0: continue
		var a = scene.instantiate()
		a.crafted.connect(_craft)
		items_container_craft.add_child(a)
		a.set_data(item)

func _craft(item: ItemRes):
	var ok = true
	$AudioStreamPlayer.play()
	$AudioStreamPlayer2.play()
	
	for k in item.recipe.keys():
		var a = item.recipe[k]
		
		if not k in Game.gm.player.inventory: ok = false; break
		if Game.gm.player.inventory[k] < a: ok = false; break
		
	if ok:
		for k in item.recipe.keys():
			var a = item.recipe[k]
			Game.gm.player.inventory[k] -= a
		if item.id in Game.gm.player.inventory: 
			Game.gm.player.inventory[item.id] += 1
		else:
			Game.gm.player.inventory[item.id] = 1
			print(item.id)
			if item.id == 200 and "first_arcade_machine" not in Save.config:
				Game.gm.player.add_boombox(7)
				Save.save("first_arcade_machine", true)
			if item.id == 300 and "first_casino_machine" not in Save.config:
				Game.gm.player.add_boombox(9)
				Save.save("first_casino_machine", true)

	Game.gm.player.update_items_ui()
 
	for c in items_container_craft.get_children(): c.update_button()

func _on_shovel_pressed() -> void:
	if Game.gm.player.money >= 1999:
		Game.gm.player.money -= 1999
		Save.save("shovel-bought",true)
		shovel.disabled = true
		shovel.text = "PURCHASED"
		Game.gm.player.give_item(2,1)
		$hit.play()


func _on_cure_pressed() -> void:
	if Game.gm.player.money >= 500000:
		Game.gm.player.money -= 500000
		Save.save("cure-bought",true)
		cure.disabled = true
		cure.text = "PURCHASED"
		Game.gm.final()
		$hit.play()


func _on_back_pressed() -> void:
	if Game.gm.player.money >= 100_000:
		Game.gm.player.money -= 100_000
		Save.save("back-bought",true)
		back.disabled = true
		back.text = "PURCHASED"
		Game.gm.get_node("Sign").visible = true
		$hit.play()

@onready var animation_player_cops: AnimationPlayer = $"../../../cops/AnimationPlayer"

func _on_depositbutton_pressed() -> void:
	Game.gm.player.money += Game.gm.player.inventory[115]
	Game.gm.player.inventory[115] = 0
	Game.gm.player.update_items_ui()
	$TabContainer/Deposit/AudioStreamPlayer.play()
	
	if not Save.config.get("cops",false) and Save.config.get("first_casino_machine",false):
		animation_player_cops.play("a")
		Game.gm.shop.toggle_shop(false)
		await get_tree().create_timer(6.0).timeout
		Save.save("cops",true)
		Game.gm.player.add_boombox(10)


func _on_tab_container_tab_clicked(tab: int) -> void:
	$hit.play()
