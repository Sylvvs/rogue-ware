extends Minigame

const LANE_HEIGHT  := 70
const LANE_COUNT   := 6
const GAME_WIDTH   := 1152

var lane_index: int = 0
var moving: bool = false
var active_cars: Array = []

@onready var player: CharacterBody2D = $PlayerBody
@onready var anim_tree: AnimationTree = $PlayerBody/AnimationTree
@onready var player_sprite: Sprite2D = $PlayerBody/Sprite2D
var anim_state: AnimationNodeStateMachinePlayback

var car_scene: PackedScene = preload("res://scenes/minigames/CrossyRoad/Car.tscn")

func start() -> void:
	instruction_text = "Cross the road without getting hit!"
	time_limit = 25
	time_limit = clamp(ceil(time_limit - (5 * mult)),5,20)
	anim_state = anim_tree.get("parameters/playback")
	anim_tree.active = true
	_build_background()
	player.position = _lane_center(0)
	_pre_populate_cars()
	_spawn_cars_for_all_lanes()

func stop() -> void:
	emit_signal("game_lost")

func _lane_y(index: int) -> float:
	return (7 - index) * LANE_HEIGHT + LANE_HEIGHT / 2.0

func _lane_center(index: int) -> Vector2:
	return Vector2(GAME_WIDTH / 2.0, _lane_y(index))

func _build_background() -> void:
	var square_size := 20
	var cols := int(GAME_WIDTH / square_size) + 1
	var rows := int(LANE_HEIGHT / square_size) + 1
	for row in range(rows):
		for col in range(cols):
			var sq := ColorRect.new()
			sq.color = Color.WHITE if (row + col) % 2 == 0 else Color.BLACK
			sq.size = Vector2(square_size, square_size)
			sq.position = Vector2(col * square_size, row * square_size)
			add_child(sq)
			move_child(sq, 0)

	var road := ColorRect.new()
	road.color = Color(0.2, 0.2, 0.2)
	road.size = Vector2(GAME_WIDTH, LANE_COUNT * LANE_HEIGHT)
	road.position = Vector2(0, LANE_HEIGHT)
	add_child(road)
	move_child(road, 0)

	var pave_start := ColorRect.new()
	pave_start.color = Color(0.5, 0.5, 0.5)
	pave_start.size = Vector2(GAME_WIDTH, LANE_HEIGHT)
	pave_start.position = Vector2(0, 7 * LANE_HEIGHT)
	add_child(pave_start)
	move_child(pave_start, 0)

	for i in range(1, LANE_COUNT):
		var x := 0.0
		var dash_width := 40.0
		var gap_width := 50.0
		var y := (i + 1) * LANE_HEIGHT - 2.0
		while x < GAME_WIDTH:
			var dash := ColorRect.new()
			dash.color = Color(1.0, 1.0, 1.0, 1.0)
			dash.size = Vector2(dash_width, 4)
			dash.position = Vector2(x, y)
			add_child(dash)
			x += dash_width + gap_width

func _pre_populate_cars() -> void:
	for i in range(1, LANE_COUNT + 1):
		var go_right: bool = (i % 2 == 0)
		var speed: float = randf_range(120.0, 260.0)
		var count: int = randi_range(3, 5)
		for j in range(count):
			var car: Node2D = car_scene.instantiate()
			car.speed = speed * (1.0 if go_right else -1.0)
			car.position = Vector2(
				randf_range(0, GAME_WIDTH),
				_lane_y(i)
			)
			active_cars.append(car)
			add_child(car)
			_randomize_car_sprite(car)

func _spawn_cars_for_all_lanes() -> void:
	for i in range(1, LANE_COUNT + 1):
		var go_right: bool = (i % 2 == 0)
		var speed: float = randf_range(120.0, 260.0)
		var interval: float = randf_range(1.0, 2.0)
		_start_lane_spawner(i, go_right, speed, interval)

func _start_lane_spawner(lane: int, go_right: bool, speed: float, interval: float) -> void:
	var timer := Timer.new()
	timer.wait_time = interval
	timer.autostart = true
	timer.timeout.connect(func(): _spawn_car(lane, go_right, speed))
	add_child(timer)

func _randomize_car_sprite(car: Node2D) -> void:
	var pick: int = randi_range(1, 9)
	var flip: bool = car.speed < 0
	for i in range(1, 10):
		var s := car.get_node_or_null("Car_%d" % i) as Sprite2D
		if s:
			s.visible = (i == pick)
			s.flip_h = flip
			s.scale = Vector2(1.5, 1.5)

func _spawn_car(lane: int, go_right: bool, speed: float) -> void:
	var car: Node2D = car_scene.instantiate()
	car.speed = speed * (1.0 if go_right else -1.0)
	car.position = Vector2(
		-80.0 if go_right else GAME_WIDTH + 80.0,
		_lane_y(lane)
	)
	active_cars.append(car)
	add_child(car)
	_randomize_car_sprite(car)

func _process(_delta: float) -> void:
	for car in active_cars.duplicate():
		if car.position.x < -200 or car.position.x > GAME_WIDTH + 200:
			active_cars.erase(car)
			car.queue_free()
			continue

		var diff: Vector2 = car.position - player.position
		if abs(diff.x) < 50 and abs(diff.y) < 35:
			_on_hit()
			return

const PLAYER_SPEED := 400.0

func _physics_process(_delta: float) -> void:
	var dir_x: float = 0.0
	if Input.is_action_pressed("walk_left"):
		dir_x = -1.0
	elif Input.is_action_pressed("walk_right"):
		dir_x = 1.0

	if dir_x != 0.0:
		player.velocity.x = dir_x * PLAYER_SPEED
	else:
		player.velocity.x = move_toward(player.velocity.x, 0.0, PLAYER_SPEED)

	if not moving:
		anim_state.travel("idle")

	if Input.is_action_pressed("walk_left"):
		(player.get_node("Sprite2D") as Sprite2D).flip_h = true
	elif Input.is_action_pressed("walk_right"):
		(player.get_node("Sprite2D") as Sprite2D).flip_h = false

	player.velocity.y = 0.0
	player.move_and_slide()
	player.position.x = clamp(player.position.x, 40, GAME_WIDTH - 40)

func _unhandled_input(event: InputEvent) -> void:
	if moving:
		return
	if event.is_action_pressed("up"):
		if lane_index < 7:
			_move_player_lane(lane_index + 1, "jump")
	elif event.is_action_pressed("down"):
		if lane_index > 0:
			_move_player_lane(lane_index - 1, "jump")

func _move_player_lane(new_index: int, anim: String) -> void:
	moving = true
	lane_index = new_index
	anim_state.travel(anim)
	var tween := create_tween()
	tween.tween_property(player, "position:y", _lane_y(lane_index), 0.1)
	tween.tween_callback(func():
		moving = false
		anim_state.travel("idle")
		if lane_index == 7:
			_on_win()
	)

func _on_hit() -> void:
	emit_signal("game_lost")

func _on_win() -> void:
	emit_signal("game_won")
