extends Minigame

@onready var apple = $Apple
@onready var bomb = $Bomb
@onready var green_apple = $"Green Apple"
@onready var shoe = $Shoe
@onready var number_input = $NumberInput

var rng = RandomNumberGenerator.new()
var objects = ["red apples","bombs","green apples","shoes"]

var random_number = randi_range(0,3)
var chosen_object = objects[random_number]
var apple_amount = randi_range(2,7)
var bomb_amount = randi_range(2,7)
var green_apple_amount = randi_range(2,7)
var shoe_amount = randi_range(2,7)
var amounts = [apple_amount, bomb_amount, green_apple_amount, shoe_amount]
	
func start():

	
	time_limit = 10
	instruction_text = "Count how many " + chosen_object + " are on screen"
	
	
	for i in range (apple_amount):
		var new_apple = apple.duplicate()
		add_child(new_apple)
		new_apple.visible = true
		new_apple.position = get_random_pos()
	for i in range(bomb_amount):
		var new_bomb = bomb.duplicate()
		add_child(new_bomb)
		new_bomb.visible = true
		new_bomb.position = get_random_pos()
	for i in range(green_apple_amount):
		var new_green_apple = green_apple.duplicate()
		add_child(new_green_apple)
		new_green_apple.visible = true
		new_green_apple.position = get_random_pos()
	for i in range(shoe_amount):
		var new_shoe = shoe.duplicate()
		add_child(new_shoe)
		new_shoe.visible = true
		new_shoe.position = get_random_pos()
	number_input.grab_focus()
	
func get_random_pos():
	return Vector2(
	rng.randi_range(0,get_viewport().get_visible_rect().size.x-100),
	rng.randi_range(0,get_viewport().get_visible_rect().size.y-250)
	)
	
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			get_viewport().set_input_as_handled()
			on_guess_submitted()

func on_guess_submitted():
	if str(amounts[random_number]) == number_input.text:
		emit_signal("game_won")
	else:
		emit_signal("game_lost")
	pass
