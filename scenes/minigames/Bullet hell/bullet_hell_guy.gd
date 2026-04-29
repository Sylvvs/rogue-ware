extends CharacterBody2D

@export var health = 3
const SPEED = 300
const slow_speed = 150
var invincible = false
var invincible_timer = 0.0
const invincible_duration = 1.0
@onready var anim = $AnimationPlayer
@onready var sprite = $Sprite2D


func _physics_process(delta: float) -> void:
	var current_speed = slow_speed if Input.is_action_pressed('walk_slow') else SPEED
	var direction = Vector2(Input.get_axis("walk_left", "walk_right"), Input.get_axis("up", "down"))
	if direction != Vector2.ZERO:
		velocity = direction.normalized() * current_speed
		if abs(direction.x) > abs(direction.y):
			if direction.x > 0:
				sprite.flip_h = false
				play_anim("Run_Right")
			else:
				sprite.flip_h = true
				play_anim("Run_Right")
		else:
			if direction.y > 0:
				play_anim("Run_Down")
			else:
				play_anim("Run_Up")
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
		play_anim("Idle")

	move_and_slide()
	if invincible:
		invincible_timer += delta
		if invincible_timer >= invincible_duration:
			invincible = false
			invincible_timer = 0.0

func play_anim(name: String):
	if anim.current_animation == "Hit":
		return
	if anim.current_animation != name:
		anim.play(name)
		
		
