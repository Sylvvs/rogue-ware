extends Minigame

@onready var apple = $Apple
@onready var bomb = $Bomb

func start():
	instruction_text = "Click the apples, not the bombs!"
	time_limit = 7
	
	for i in range(3):
		var new_bomb = bomb.duplicate()
		add_child(new_bomb)
		new_bomb.visible = true
		new_bomb.position = get_random_pos()
	
	for i in range(5):
		var new_apple = apple.duplicate()
		add_child(new_apple)
		new_apple.visible = true
		new_apple.position = get_random_pos()
		new_apple.name = "Apple%d" % i
		new_apple.button_down.connect(_on_apple_button_down.bind(new_apple))
		

func stop():
	emit_signal("game_lost")

var rng = RandomNumberGenerator.new()
func get_random_pos():
	return Vector2(
	rng.randi_range(0,get_viewport().size.x-100),
	rng.randi_range(0,get_viewport().size.y-250)
	)

func _on_bomb_button_down() -> void:
	emit_signal("game_lost")


func _on_apple_button_down(sender: TextureButton) -> void:
	sender.visible = false
	sender.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var apples_left = 0
	for child in get_children():
		if child.name.begins_with("Apple") and child.visible == true:
			apples_left += 1
	if apples_left == 0:
		emit_signal("game_won")
