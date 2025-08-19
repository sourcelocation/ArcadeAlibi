extends ColorRect

var res : Vector2
var o_res = Vector2(2560, 1440)
var scale_factor
var pxl_size = 64 * 3

var pman_fps = 15.0
var pman_pos : Vector2
var pman_dir : Vector2
var pman_wdir := Vector2(1,0)
var interval := 0.0
var max_interval := 0.0
var ghosts: Array = []
var colors = [Color.RED, Color.PINK, Color.CYAN, Color.ORANGE]
var num_ghosts = 4
var orbs = 0
var total_orbs = 0

var score_label = Label.new()

var map = [
	[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
	[1,3,3,3,3,3,3,3,3,1,3,3,3,3,3,3,3,3,1],
	[1,3,1,1,3,1,1,1,3,1,3,1,1,1,3,1,1,3,1],
	[1,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,1],
	[1,3,1,1,3,1,3,1,1,1,1,1,3,1,3,1,1,3,1],
	[1,3,3,3,3,1,3,3,3,1,3,3,3,1,3,3,3,3,1],
	[1,1,1,1,3,1,1,1,3,1,3,1,1,1,3,1,1,1,1],
	[2,2,2,1,3,1,3,3,3,3,3,3,3,1,3,1,2,2,2],
	[1,1,1,1,3,1,3,1,1,0,1,1,3,1,3,1,1,1,1],
	[3,3,3,3,3,3,3,1,0,0,0,1,3,3,3,3,3,3,3],
	[1,1,1,1,3,1,3,1,1,1,1,1,3,1,3,1,1,1,1],
	[2,2,2,1,3,1,3,3,3,3,3,3,3,1,3,1,2,2,2],
	[1,1,1,1,3,1,3,1,1,1,1,1,3,1,3,1,1,1,1],
	[1,3,3,3,3,3,3,3,3,1,3,3,3,3,3,3,3,3,1],
	[1,3,1,1,3,1,1,1,3,1,3,1,1,1,3,1,1,3,1],
	[1,3,3,1,3,3,3,3,3,3,3,3,3,3,3,1,3,3,1],
	[1,1,3,1,3,1,3,1,1,1,1,1,3,1,3,1,3,1,1],
	[1,3,3,3,3,1,3,3,3,1,3,3,3,1,3,3,3,3,1],
	[1,3,1,1,1,1,1,1,3,1,3,1,1,1,1,1,1,3,1],
	[1,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,1],
	[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
]

func _ready() -> void:
	res = get_viewport_rect().size
	scale_factor = res / o_res
	pxl_size *= scale_factor.x
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	#res = Vector2(DisplayServer.window_get_size().x, DisplayServer.window_get_size().y)
	#scale_factor = res / o_res
	#pxl_size *= scale_factor.x
	var pman_start = Vector2(1 * pxl_size + res.x / 2 - map[0].size() * pxl_size / 2 + pxl_size/2, 1 * pxl_size + pxl_size/2)
	pman_pos = pman_start
	pman_dir = Vector2(1,0)
	max_interval = 1/pman_fps
	for i in range(num_ghosts):
		var ghost = {
			"color": colors[i],
			"pos": Vector2.ZERO,
			"dir": Vector2.ZERO,
			"wdir": Vector2.ZERO,
			"map_x": 0,
			"map_y": 0
		}
		ghosts.append(ghost)
		ghosts[i].pos = Vector2((max(i,1) + 7) * pxl_size + res.x / 2 - map[0].size() * pxl_size / 2 + pxl_size/2, 9 * pxl_size + pxl_size/2)

	score_label.text = "Score: "
	add_child(score_label)

	for i in range(map.size()):
		for j in range(map[0].size()):
			if map[i][j] == 3:
				total_orbs += 1

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("ui_right"):
		pman_wdir = Vector2(1,0)
	if Input.is_action_pressed("ui_left"):
		pman_wdir = Vector2(-1,0)
	if Input.is_action_pressed("ui_up"):
		pman_wdir = Vector2(0,-1)
	if Input.is_action_pressed("ui_down"):
		pman_wdir = Vector2(0,1)

	interval += delta
	if interval >= max_interval:
		for ghost in ghosts:
			_update_ghost(ghost)
		update_pman()
		interval = 0.0

	score_label.text = "Score: " + str(orbs)

	if total_orbs <= 0:
		reset_map()

	queue_redraw()

func _update_ghost(ghost):
	var map_coords = get_map_coords(ghost.pos)
	ghost.map_x = map_coords.x
	ghost.map_y = map_coords.y
	ghost.wdir = [Vector2.RIGHT, Vector2.LEFT, Vector2.DOWN, Vector2.UP].pick_random()
	if abs(ghost.pos.x / pxl_size - floor(ghost.pos.x / pxl_size)) == 0 and abs(ghost.pos.y / pxl_size - floor(ghost.pos.y / pxl_size)) == 0.5:
		ghost.dir = ghost.wdir
		if ghost.wdir.x != 0 and (map[ghost.map_y][ghost.map_x + ghost.wdir.x] != 0 and map[ghost.map_y][ghost.map_x + ghost.wdir.x] != 3):
			ghost.dir = Vector2.ZERO
		if ghost.wdir.y != 0 and (map[ghost.map_y + ghost.wdir.y][ghost.map_x] != 0 and map[ghost.map_y + ghost.wdir.y][ghost.map_x] != 3):
			ghost.dir = Vector2.ZERO
	ghost.pos += pxl_size / 4 * ghost.dir

func update_pman():
	var map_coords = get_map_coords(pman_pos)
	var map_x = map_coords.x
	var map_y = map_coords.y
	for ghost in ghosts:
		if map_x == ghost.map_x and map_y == ghost.map_y:
			get_tree().reload_current_scene()
	if map[map_y][map_x] == 3:
		map[map_y][map_x] = 0
		orbs += 100
		max_interval -= 0.0001
		total_orbs -= 1
	if abs(pman_pos.x / pxl_size - floor(pman_pos.x / pxl_size)) == 0 and abs(pman_pos.y / pxl_size - floor(pman_pos.y / pxl_size)) == 0.5:
		pman_dir = pman_wdir
		if map_x + pman_wdir.x > map[0].size()-1:
			pman_pos.x = 0 * pxl_size + res.x / 2 - map[0].size() * pxl_size / 2 + pxl_size/2
		elif map_x + pman_wdir.x < 0:
			pman_pos.x = (map[0].size() - 1) * pxl_size + res.x / 2 - map[0].size() * pxl_size / 2 + pxl_size/2
		elif pman_wdir.x != 0 and (map[map_y][map_x + pman_wdir.x] !=  0 and map[map_y][map_x + pman_wdir.x] != 3):
			pman_dir = Vector2.ZERO
		if pman_wdir.y != 0 and (map[map_y + pman_wdir.y][map_x] != 0 and map[map_y + pman_wdir.y][map_x] != 3):
			pman_dir = Vector2.ZERO
	pman_pos += pxl_size / 4 * pman_dir

func get_map_coords(pman_pos: Vector2) -> Vector2i:
	var map_x = (pman_pos.x - res.x / 2 + map[0].size() * pxl_size / 2 - pxl_size / 2) / pxl_size
	var map_y = (pman_pos.y - pxl_size / 2) / pxl_size
	return Vector2i(int(map_x), int(map_y))

func _draw() -> void:
	var offset_x = res.x / 2 - map[0].size() * pxl_size / 2
	for i in range(map.size()):
		for j in range(map[i].size()):
			var sqr = Rect2(Vector2(j * pxl_size + offset_x, i * pxl_size), Vector2(pxl_size, pxl_size))
			if map[i][j] == 1:
				draw_rect(sqr, Color.SPRING_GREEN)
			elif map[i][j] == 2:
				draw_rect(sqr, Color.BLACK)
			elif map[i][j] == 3:
				draw_circle(Vector2(j * pxl_size + res.x / 2 - map[0].size() * pxl_size / 2 + pxl_size/2, i * pxl_size + pxl_size/2), 5, Color.YELLOW)

	draw_circle(pman_pos, 20, Color.YELLOW)
	for ghost in ghosts:
		draw_circle(ghost.pos, 20, ghost.color)

func reset_map():
	var pman_start = Vector2(1 * pxl_size + res.x / 2 - map[0].size() * pxl_size / 2 + pxl_size/2, 1 * pxl_size + pxl_size/2)
	pman_pos = pman_start
	pman_dir = Vector2(1,0)
	for i in range(ghosts.size()):
		ghosts[i].pos = Vector2((max(i,1) + 7) * pxl_size + res.x / 2 - map[0].size() * pxl_size / 2 + pxl_size/2, 9 * pxl_size + pxl_size/2)
	for i in range(map.size()):
		for j in range(map[0].size()):
			if map[i][j] == 0:
				map[i][j] = 3
	score_label.text = "Score: "
