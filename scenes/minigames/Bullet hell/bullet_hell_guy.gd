extends CharacterBody2D

@export var health = 3
const SPEED = 300.0

@onready var anim = $AnimationPlayer
@onready var sprite = $Sprite2D

func _physics_process(delta: float) -> void:
	var direction = Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down"))
	if direction != Vector2.ZERO:
		velocity = direction.normalized() * SPEED
		
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


func play_anim(name: String):
	if anim.current_animation != name:
		anim.play(name)
		
