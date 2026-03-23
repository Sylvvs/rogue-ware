extends Minigame

@onready var center = $Area2D
@export var bullet_scene: PackedScene

var spawn_timer = 0.0
var time_passed = 0.0
var phase_timer = 0.0
var current_phase = 2

var phases = [
	{
		"name": "circle",
		"duration": 3.0,
		"bullets": 12,
		"speed": 200
	},
	{
		"name": "petals",
		"duration": 4.0,
		"bullets": 16,
		"speed": 300,
		"k": 10
	},
	{
		"name": "spiral",
		"duration": 15.0,
		"bullets": 20,
		"speed": 300
	}
]

func start():
	instruction_text = "Dodge the bullets"
	time_limit = 10

func _process(delta):
	spawn_timer += delta
	time_passed += delta
	phase_timer += delta
	
	var phase = phases[current_phase]
	
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


func spawn_circle(phase):
	for i in range(phase.bullets):
		var bullet = bullet_scene.instantiate()
		
		var angle = i * TAU / phase.bullets
		var dir = Vector2(cos(angle), sin(angle))
		
		bullet.position = center.position
		bullet.bullet_direction = dir * phase.speed
		
		add_child(bullet)

func spawn_petals(phase):
	var k = phase.k
	
	for i in range(phase.bullets):
		var bullet = bullet_scene.instantiate()
		
		var base_angle = i * TAU / phase.bullets
		var r = cos(k * base_angle + time_passed)
		
		var dir = Vector2(cos(base_angle), sin(base_angle)) * r
		
		bullet.position = center.position
		bullet.bullet_direction = dir * phase.speed
		
		add_child(bullet)

func spawn_spiral(phase):
	for i in range(phase.bullets):
		var bullet = bullet_scene.instantiate()
		
		var angle = i * TAU / phase.bullets + time_passed * 1.8
		
		var dir = Vector2(cos(angle), sin(angle))
		
		bullet.position = center.position
		bullet.bullet_direction += dir * phase.speed
		
		add_child(bullet)
