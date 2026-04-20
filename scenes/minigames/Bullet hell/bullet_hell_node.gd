extends Minigame
@onready var bullet_hell_guy = $BulletHellGuy
@onready var anim = $BulletHellGuy/AnimationPlayer
@onready var health_text = $Lives
func start():
	instruction_text = "Survive The Bullets... and don't die"
	time_limit = 20
	
	time_limit = clamp(ceil(time_limit * mult),20,60)

func _process(delta: float) -> void:
	health_text.text = "Lives: " + str(bullet_hell_guy.health)
	if bullet_hell_guy.health <= 0:
		die()
		return
func stop():
	emit_signal("game_won")

func die():
	emit_signal("game_lost")
	
