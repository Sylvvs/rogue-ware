extends Area2D

var hit_time: float
var approach_duration: float
var has_been_hit = false
var target_position: Vector2
var initialized = false
var notes_missed = 0
@onready var ring = $Ring      
@onready var circle = $Circle  
@onready var perfect_hit_sound = $PerfectHitSound

const perfect_window = 0.25
const good_window = 0.15
const hit_radius = 100

var last_seen_cursor = -99
const grace_period = 0.1


func _process(delta):
	if not initialized:
		position = target_position
		scale = Vector2(0.1,0.1)
		initialized = true
		return
	if hit_time - Conductor.current_time < grace_period:
		var mouse_pos = get_global_mouse_position()
		var dist = global_position.distance_to(mouse_pos)
		if dist < hit_radius:
			last_seen_cursor = Conductor.current_time

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
		if global_position.distance_to(mouse_pos) < hit_radius:
			register_hit("Perfect")
		else:
			if Conductor.current_time - last_seen_cursor < grace_period:
				register_hit("Perfect")
			else:
				register_miss()

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_pos = get_global_mouse_position()
		if position.distance_to(mouse_pos) < hit_radius: 
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
		notes_missed += 1
		register_miss()

func register_hit(rating: String):
	var i = Conductor.mult_levels.find(Conductor.multiplier)
	has_been_hit = true
	perfect_hit_sound.reparent(get_tree().current_scene)
	perfect_hit_sound.play()
	Conductor.combo += 1
	Conductor.successful_hits += 1
	Conductor.total_notes += 1
	if i < Conductor.mult_levels.size() - 1:
		if Conductor.combo % 4 == 0: 
			Conductor.multiplier = Conductor.mult_levels[i + 1]
	var base_score = 115
	
	if rating == "Perfect":
		base_score = 115
		
	Conductor.score += base_score * Conductor.multiplier
	queue_free()

func register_miss():
	var i = Conductor.mult_levels.find(Conductor.multiplier)
	has_been_hit = true
	Conductor.notes_missed += 1
	Conductor.total_notes += 1
	Conductor.combo = 0
	if i > 0:
		Conductor.multiplier = Conductor.mult_levels[i - 1]
	#Conductor.multiplier = max(1, Conductor.multiplier/2)
	queue_free()
