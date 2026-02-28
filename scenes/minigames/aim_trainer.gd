extends Minigame

@onready var apple = $Apple
@onready var bomb = $Bomb

func start():
	instruction_text = "Click the apples, not the bombs!"
	time_limit = 5
	
	for i in range(3):
		var new_bomb = bomb.duplicate()
		add_child(new_bomb)
		new_bomb.visible = true
	
	for i in range(5):
		var new_apple = apple.duplicate()
		add_child(new_apple)
		new_apple.visible = true
		new_apple.name = "Apple%d" % i
		new_apple.button_down.connect(_on_apple_button_down.bind(new_apple))

func stop():
	for child in get_children():
		if child.name.begins_with("Apple") and child.visible == true:
			emit_signal("game_lost")
			return
	emit_signal("game_won")



func _on_bomb_button_down() -> void:
	emit_signal("game_lost")




func _on_apple_button_down(sender: TextureButton) -> void:
	sender.visible = false
	sender.mouse_filter = Control.MOUSE_FILTER_IGNORE
