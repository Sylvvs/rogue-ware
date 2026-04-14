extends Area2D

var hit_time: float
var approach_duration: float
var has_been_hit = false
var target_position: Vector2
var initialized = false
@onready var ring = $Ring      
@onready var circle = $Circle  
@onready var perfect_hit_sound = $PerfectHitSound

const perfect_window = 0.08
const good_window = 0.15
const hit_radius = 62

func _process(delta):
	if not initialized:
		position = target_position
		scale = Vector2(0.1,0.1)
		initialized = true
		return

	if has_been_hit:
		return
	var time_left = hit_time - Conductor.current_time
	var progress = clamp(1.0 - (time_left / approach_duration), 0.0, 1.0)  # 0% til 100%
	var s = lerp(0.1, 1.0, progress)
	scale = Vector2(s, s)
	var ring_scale = lerp(2.5, 1.0, progress)
	ring.scale = Vector2(ring_scale, ring_scale)
	
	# Auto miss
	if Conductor.current_time > hit_time:
		var mouse_pos = get_global_mouse_position()
		var dist = global_position.distance_to(mouse_pos)
		print("dist: ", dist, " hit_radius: ", hit_radius)
		if global_position.distance_to(mouse_pos) < hit_radius:
			register_hit("Perfect")
		else:
			register_miss()

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_pos = get_global_mouse_position()
		if position.distance_to(mouse_pos) < 60: 
			try_hit()

func try_hit():
	if has_been_hit:
		return
	var diff = abs(Conductor.current_time - hit_time)
	if diff <= perfect_window:
		register_hit("Perfect")
	elif diff <= good_window:
		register_hit("Good")
	else:
		register_miss()

func register_hit(rating: String):
	has_been_hit = true
	perfect_hit_sound.play()
	print(rating)
	await perfect_hit_sound.finished
	queue_free()

func register_miss():
	has_been_hit = true
	print("Miss")
	queue_free()
