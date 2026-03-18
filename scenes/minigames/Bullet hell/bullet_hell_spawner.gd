extends Minigame

@onready var center = $Area2D

@export var bullet_scene: PackedScene
@export var bullet_speed = 200
@export var bullets_per_ring = 12
@export var spawn_rate = 0.5

var spawn_timer = 0.0

func start():
	instruction_text = "Dodge the bullets"
	time_limit = 10

func _process(delta):
	spawn_timer += delta
	
	if spawn_timer >= spawn_rate:
		spawn_timer = 0
		spawn_ring()
		
func spawn_ring():
	for i in range(bullets_per_ring):
		var bullet = bullet_scene.instantiate()
		
		var angle = i * TAU / bullets_per_ring
		var direction = Vector2(cos(angle), sin(angle))
		
		bullet.position = center.position
		bullet.velocity = direction * bullet_speed
		
		add_child(bullet)
