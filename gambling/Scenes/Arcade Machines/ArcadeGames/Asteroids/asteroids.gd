extends ColorRect

var ship_pos: Vector2
var ship_spd := Vector2.ZERO
var ship_angle := 0.0
var turn_speed := 3.0
var thrust := 200.0
var friction := 0.99
var respawn_timer := 0.0
var respawn_delay := 2.0
var is_alive := true

var bullets: Array = []
var bullet_speed := 500.0
var bullet_lifetime := 1.5
var shoot_cooldown := 0.2
var shoot_timer := 0.0

var asteroids: Array = []
var asteroid_min_size := 20
var asteroid_max_size := 60
var safe_radius := 150.0

var score := 0
var score_label: Label

func _ready() -> void:
	self.color = Color(0, 0, 0, 0)
	randomize()
	ship_pos = DisplayServer.window_get_size() / 2
	_spawn_asteroids(5)

	score_label = Label.new()
	score_label.text = "Score: 0"
	score_label.set_position(Vector2(10, 10))
	score_label.set("theme_override_colors/font_color", Color.WHITE)
	add_child(score_label)

func _physics_process(delta: float) -> void:
	if is_alive:
		_ship_controls(delta)
		_check_ship_collision()
	else:
		respawn_timer -= delta
		score = 0
		score_label.text = "Score: 0"
		if respawn_timer <= 0.0:
			_respawn_ship()

	shoot_timer -= delta
	if Input.is_action_pressed("ui_accept") and shoot_timer <= 0.0 and is_alive:
		_shoot_bullet()
		shoot_timer = shoot_cooldown

	for b in bullets:
		b.pos += b.dir * bullet_speed * delta
		b.life -= delta
	bullets = bullets.filter(func(b): return b.life > 0)

	for a in asteroids:
		a.pos += a.vel * delta

	var screen = DisplayServer.window_get_size()
	asteroids = asteroids.filter(func(a):
		return a.pos.x >= 0 and a.pos.x <= screen.x and a.pos.y >= 0 and a.pos.y <= screen.y
	)

	var new_asteroids = []
	var remaining_bullets = []
	for b in bullets:
		var hit = false
		for a in asteroids:
			if b.pos.distance_to(a.pos) < a.size:
				hit = true
				score += int(a.size)
				score_label.text = "Score: %d" % score

				if a.size > asteroid_min_size * 1.5:
					for i in range(2):
						var na = {
							"pos": a.pos,
							"vel": Vector2(randf_range(-100,100), randf_range(-100,100)),
							"size": a.size * 0.5
						}
						new_asteroids.append(na)
				break
		if not hit:
			remaining_bullets.append(b)

	asteroids = asteroids.filter(func(a):
		return not bullets.any(func(b): return b.pos.distance_to(a.pos) < a.size)
	) + new_asteroids
	bullets = remaining_bullets

	if asteroids.is_empty():
		var extra = int(score / 200)
		var base = 5
		_spawn_asteroids(base + extra)


	queue_redraw()

func _ship_controls(delta: float) -> void:
	if Input.is_action_pressed("ui_left"):
		ship_angle -= turn_speed * delta
	if Input.is_action_pressed("ui_right"):
		ship_angle += turn_speed * delta
	if Input.is_action_pressed("ui_up"):
		var forward = Vector2.RIGHT.rotated(ship_angle)
		ship_spd += forward * thrust * delta

	ship_spd *= friction
	ship_pos += ship_spd * delta
	ship_pos = _wrap_position(ship_pos)

func _check_ship_collision() -> void:
	for a in asteroids:
		if ship_pos.distance_to(a.pos) < a.size + 15:
			is_alive = false
			respawn_timer = respawn_delay
			break

func _respawn_ship() -> void:
	ship_pos = DisplayServer.window_get_size() / 2
	ship_spd = Vector2.ZERO
	ship_angle = 0.0
	is_alive = true

func _shoot_bullet():
	var forward = Vector2.RIGHT.rotated(ship_angle)
	var nose = ship_pos + forward * 30
	var bullet = {
		"pos": nose,
		"dir": forward,
		"life": bullet_lifetime
	}
	bullets.append(bullet)

func _spawn_asteroids(count: int):
	var screen = DisplayServer.window_get_size()
	for i in range(count):
		var pos: Vector2
		while true:
			pos = Vector2(randi() % screen.x, randi() % screen.y)
			if pos.distance_to(ship_pos) > safe_radius:
				break
		var a = {
			"pos": pos,
			"vel": Vector2(randf_range(-100,100), randf_range(-100,100)),
			"size": randf_range(asteroid_min_size, asteroid_max_size)
		}
		asteroids.append(a)

func _wrap_position(pos: Vector2) -> Vector2:
	var screen = DisplayServer.window_get_size()
	if pos.x < 0:
		pos.x = screen.x
	elif pos.x > screen.x:
		pos.x = 0
	if pos.y < 0:
		pos.y = screen.y
	elif pos.y > screen.y:
		pos.y = 0
	return pos

func _draw() -> void:
	if is_alive:
		var forward = Vector2.RIGHT.rotated(ship_angle)
		var left = forward.rotated(2.5) * 20
		var right = forward.rotated(-2.5) * 20
		var nose = ship_pos + forward * 30
		draw_polygon([nose, ship_pos + left, ship_pos + right], [Color.DIM_GRAY])
	else:
		draw_circle(ship_pos, 25, Color(1, 0, 0, 0.5))
	for b in bullets:
		draw_circle(b.pos, 3, Color.RED)

	for a in asteroids:
		draw_circle(a.pos, a.size, Color.LIGHT_GRAY)
