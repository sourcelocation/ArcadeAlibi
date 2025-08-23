extends Node3D

@export var messages_arcade: Array[String]
@export var messages_happy: Array[String]
@export var messages_angry: Array[String]
@onready var msg: Label = $SubViewport/Control/msg
@onready var money: Label = %money
@export var casino = false
var occupied_id
var earnings = 0
var needs_playtest = false

var i = 0

func _ready():
	$Vis.visible = false
	if casino:
		add_to_group("casino",true)
	else:
		add_to_group("arcade",true)
	$NPC.visible = false
	
	await get_tree().create_timer(0.1).timeout
	
	if ("occupied_id-%s" % name) in Save.config:
		occupied_id = Save.config[("occupied_id-%s" % name)]
		spawn()
		needs_playtest = false
		_playtested()

func _process(delta: float) -> void:
	if $Area3D.overlaps_body(Game.gm.player):
		if Input.is_action_pressed("Select"):
			if !occupied_id:
				if not needs_playtest:
					var t = Game.gm.player.selected_tool
					if t != null:
						var a = t >= 300 and casino
						var b = t >= 200  and t < 300 and !casino
						if a or b:
							Game.gm.player.inventory[t] -= 1
							Game.gm.player.update_items_ui()
							Game.gm.player.equip_item(null)
							occupied_id = t
							Save.save("occupied_id-%s" % name,occupied_id)
							spawn()
							$AudioStreamPlayer.play()
							for c in get_tree().get_nodes_in_group("casino"): c.toggle(false)
							for c in get_tree().get_nodes_in_group("arcade"): c.toggle(false)
							return
			if needs_playtest:
				if Input.is_action_just_pressed("Select"):
						_begin_playtest()
				
			Game.gm.player.give_item(115,earnings)
			if Game.gm.player.money > 1000 and not Save.config.get("boombox-poor",false):
				Save.save("boombox-poor",true)
				Game.gm.player.add_boombox(8)
			if Game.gm.player.money > 10000 and not Save.config.get("boombox-yap",false):
				Save.save("boombox-yap",true)
				Game.gm.player.add_boombox(11)
			earnings = 0
	
	$UI/Panel.visible = $Area3D.overlaps_body(Game.gm.player) and (occupied_id != null) and not needs_playtest
	$UI/Playtest.visible = $Area3D.overlaps_body(Game.gm.player) and needs_playtest and occupied_id
	money.text = "$" + str(earnings)
func _playtested():
	needs_playtest = false
	$NPCTimer.start()
	
func _begin_playtest():
	#_playtested()
	Game.gm.player.add_playtest(get_item_by_id(occupied_id).playtest_scene,_playtested)
	

func spawn():
	needs_playtest = true
	$StaticBody3D.set_collision_layer_value(1,true)
	var a = get_item_by_id(occupied_id).scene.instantiate()
	a.position = Vector3()
	a.rotation = Vector3()
	a.set_data(get_item_by_id(occupied_id))
	add_child(a)

func get_item_by_id(id):
	var item
	for _item in Game.gm.items:
		if _item.id == id:
			item = _item
	return item


func _on_npc_timer_timeout() -> void:
	$NPCTimerPlay.wait_time = randf_range(2.0,6.0)
	$NPCTimerPlay.start()
	$NPC.visible = true
	i = 0
	text()


func _on_npc_timer_play_timeout() -> void:
	i += 1
	$NPCTimerPlay.wait_time = randf_range(2.0,6.0)
	match occupied_id:
		200:
			earnings += randi_range(40,60)
			#Game.gm.player.give_item(115,50)
		300:
			earnings += randi_range(900,1100)
			#Game.gm.player.give_item(115,1000)
		301:
			earnings += randi_range(3000,7000)
			#Game.gm.player.give_item(115,5000)
	text()
	
func text():
	msg.text = (messages_angry.pick_random() if i > 2 else messages_happy.pick_random()) if casino else messages_arcade.pick_random()
	
func toggle(on):
	$Vis.visible = on and occupied_id == null
	if name =="ArcadePos": 
		print(name)
