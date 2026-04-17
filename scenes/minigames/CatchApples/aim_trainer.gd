extends Minigame

@onready var apple = $Apple
@onready var bomb = $Bomb

var apple_count = 5
var bomb_count = 3
func start():
	instruction_text = "Click the apples, not the bombs!"
	time_limit = 7
	bomb_count = ceil(bomb_count * mult)
	apple_count = ceil(apple_count * mult)
	for i in range(bomb_count):
		var new_bomb = bomb.duplicate()
		add_child(new_bomb)
		new_bomb.visible = true
		new_bomb.position = get_random_pos()
	
	for i in range(apple_count):
		var new_apple = apple.duplicate()
		add_child(new_apple)
		new_apple.visible = true
		new_apple.position = get_random_pos()
		new_apple.name = "Apple%d" % i
		new_apple.button_down.connect(_on_apple_button_down.bind(new_apple))
		

var rng = RandomNumberGenerator.new()
func get_random_pos():
	return Vector2(
	rng.randi_range(0,get_viewport().get_visible_rect().size.x-100),
	rng.randi_range(0,get_viewport().get_visible_rect().size.y-250)
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
