extends Minigame

@onready var center = $Area2D
@export var bullet_scene: PackedScene
@export var beam_scene: PackedScene
@onready var node_center = $"."



var spawn_timer = 0.0
var time_passed = 0.0
var phase_timer = 0.0
var current_phase = 0

var phases = [
	{
		"name": "circle",
		"duration": 3.0,
		"bullets": 32,
		"lifetime": 10,
		"speed": 200,
		"multiplier": 1
	},
	{
		"name": "petals",
		"duration": 3.0,
		"bullets": 32,
		"speed": 300,
		"lifetime": 5,
		"k": 10,
		"multiplier": 1
	},
	{
		"name": "spiral",
		"duration": 4.0,
		"bullets": 32,
		"lifetime": 10,
		"speed": 200,
		"multiplier": 1
	},
	{
		"name": "beam",
		"duration": 3,
		"bullets": 24,
		"num_beams": 8,
		"lifetime": 3,
		"speed": 1,
		"multiplier": 2
	}
]

func _process(delta):
	var phase = phases[current_phase]
	
	spawn_timer += delta 
	time_passed += delta
	phase_timer += delta
	node_center.rotation += delta/4 * phase.multiplier
	
	
	# switch phase
	if phase_timer >= phase.duration:
		phase_timer = 0
		current_phase = (current_phase + 1) % phases.size()
		
	# spawn bullets
	if spawn_timer >= 0.5:
		spawn_timer = 0
		spawn_pattern(phase)
func spawn_pattern(phase):
	match phase.name:
		"circle":
			spawn_circle(phase)
		"petals":
			spawn_petals(phase)
		"spiral":
			spawn_spiral(phase)
		"beam":
			spawn_beam(phase)


func spawn_circle(phase):
	for i in range(phase.bullets):
		var bullet = bullet_scene.instantiate()
		
		var angle = i * TAU / phase.bullets
		var dir = Vector2(cos(angle), sin(angle))
		bullet.lifetime = phase.lifetime
		bullet.position = center.position
		bullet.bullet_direction = dir * phase.speed
		
		add_child(bullet)

func spawn_petals(phase):
	var k = phase.k
	
	for i in range(phase.bullets):
		var bullet = bullet_scene.instantiate()
		
		var base_angle = i * TAU / phase.bullets
		var r = cos(k * base_angle + time_passed)
		r = sign(r) * max(abs(r), 0.3)
		var dir = Vector2(cos(base_angle), sin(base_angle)) * r
		bullet.lifetime = phase.lifetime
		bullet.position = center.position
		bullet.bullet_direction = dir * phase.speed
		
		add_child(bullet)

func spawn_spiral(phase):
	for i in range(phase.bullets):
		var bullet = bullet_scene.instantiate()
		
		var angle = i * TAU / phase.bullets + time_passed * 1.8
		
		var dir = Vector2(cos(angle), sin(angle))
		bullet.lifetime = phase.lifetime
		bullet.position = center.position
		bullet.bullet_direction += dir * phase.speed
		
		add_child(bullet)

func spawn_beam(phase):
	var beams = get_tree().get_nodes_in_group('beam')
	if beams.size() >= 24:
		return
	
	for b in range(phase.num_beams):
		var angle = b * TAU / phase.num_beams + node_center.rotation
		var dir = Vector2(cos(angle), sin(angle))
		
		for i in range(phase.bullets / phase.num_beams):
			var beam = beam_scene.instantiate()
			beam.lifetime = phase.lifetime
			beam.position = center.position + dir * i * 8.0
			beam.rotation = angle
			beam.bullet_direction = dir * phase.speed
			add_child(beam)
			
