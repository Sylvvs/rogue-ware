extends Minigame
@onready var bullet_hell_guy = $BulletHellGuy
@onready var anim = $BulletHellGuy/AnimationPlayer
func start():
	instruction_text = "Survive The Bullets"
	time_limit = 20

func _process(delta: float) -> void:
	if bullet_hell_guy.health <= 0:
		die()
		return
func stop():
	emit_signal("game_won")

func die():
	emit_signal("game_lost")
	
