extends MeshInstance3D

@export var messages_happy: Array[String]
@export var messages_angry: Array[String]
@export var casino = false
var occupied_id
var earnings = 0.0

var i = 0

func _ready():
	if casino:
		add_to_group("casino",true)
	else:
		add_to_group("arcade",true)
	$NPC.visible = false

func _process(delta: float) -> void:
	if !occupied_id:
		if $Area3D.overlaps_body(Game.gm.player):
			if Input.is_action_pressed("Select"):
				var t = Game.gm.player.selected_tool
				if t != null:
					var a = t >= 300 and casino
					var b = t >= 200  and t < 300 and !casino
					if a or b:
						Game.gm.player.inventory[t] -= 1
						Game.gm.player.update_items_ui()
						Game.gm.player.equip_item(null)
						occupied_id = t
						spawn()
	
	
	$UI.visible = $Area3D.overlaps_body(Game.gm.player)

func _playtested():
	$NPCTimer.start()
	

func spawn():
	$StaticBody3D.set_collision_layer_value(1,true)
	var a = get_item_by_id(occupied_id).scene.instantiate()
	a.position = Vector3()
	a.rotation = Vector3()
	add_child(a)
	_playtested()

func get_item_by_id(id):
	var item
	for _item in Game.gm.items:
		if _item.id == id:
			item = _item
	return item


func _on_npc_timer_timeout() -> void:
	$NPCTimerPlay.start()
	$NPC.visible = true
	i = 0
	match occupied_id:
		200:
			Game.gmplayer.money += 50.0
		300:
			Game.gmplayer.money += 1000.0
		301:
			Game.gmplayer.money += 2500.0


func _on_npc_timer_play_timeout() -> void:
	i += 1
	
