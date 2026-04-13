extends CharacterBody2D

const SPEED_ACC = 250
const SPEED_MAX = 500
const GRAVITY = 7


var last_x_dir := 0
var last_y_dir := 0
var direction := 1

@onready var sprite = $Sprite2D

func _physics_process(_delta: float) -> void:
	var input_vec := get_input_vector()
	
	if input_vec.x == -1:
		if velocity.x > -SPEED_MAX: velocity.x -= SPEED_ACC
	elif velocity.x < 0: velocity.x += SPEED_ACC
	if input_vec.x == 1:
		if velocity.x < SPEED_MAX: velocity.x += SPEED_ACC
	elif velocity.x > 0: velocity.x -= SPEED_ACC
	if abs(velocity.x) < SPEED_ACC:
		velocity.x = 0
	
	var friction = SPEED_ACC
	if velocity.x > SPEED_MAX:
		velocity.x = min(velocity.x - friction, SPEED_MAX)
	elif velocity.x < -SPEED_MAX:
		velocity.x = max(velocity.x + friction, -SPEED_MAX)
		
	velocity.y += GRAVITY
	move_and_slide()
	
	if velocity.x > 0:
		sprite.flip_h = false
		direction = 1
	elif velocity.x < 0:
		sprite.flip_h = true
		direction = -1
		
	

func get_input_vector() -> Vector2:
	last_x_dir = get_axis_dir("walk_left", "walk_right", last_x_dir)
	last_y_dir = get_axis_dir("up", "down", last_y_dir)
	return Vector2(last_x_dir, last_y_dir)
	
func get_axis_dir(neg_action: String, pos_action: String, last_dir: int) -> int:
	if Input.is_action_just_pressed(neg_action):
		last_dir = -1
	elif Input.is_action_just_pressed(pos_action):
		last_dir = 1

	elif Input.is_action_just_released(neg_action):
		if Input.is_action_pressed(pos_action):
			last_dir = 1
		else:
			last_dir = 0
	elif Input.is_action_just_released(pos_action):
		if Input.is_action_pressed(neg_action):
			last_dir = -1
		else:
			last_dir = 0

	return last_dir
