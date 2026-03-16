extends Minigame

@onready var grid = $GridContainer
@onready var timer = $Timer

var button_array = []
var index = 0
var memory_number = 3
var game_state = false

var style_clicked = StyleBoxFlat.new()


var style = StyleBoxFlat.new()

func start():
	instruction_text = "Remember the squares"
	time_limit = 6 + memory_number
	
	style.bg_color = Color(0.5,0.5,0.5,1)
	style_clicked.bg_color = Color(1,1,1,1)
	for child in grid.get_children():
		child.add_theme_stylebox_override("normal", style)
		child.add_theme_stylebox_override("pressed",style_clicked)
		child.pressed.connect(Callable(self, "on_button_pressed").bind(child))
	
	for i in range(memory_number):
		button_array.append(grid.get_children().pick_random())
	
	timer.start()

func _on_timer_timeout() -> void:
	if index >= memory_number:
		game_state = true
		return
	button_array[index].add_theme_stylebox_override("normal", style_clicked)
	flash(index)
	index += 1
	

func flash(index):
	await get_tree().create_timer(0.5).timeout
	button_array[index].add_theme_stylebox_override("normal", style)
	pass
	
func on_button_pressed(button: Button):
	if game_state == false:
		return
	if button == button_array[0]:
		button_array.pop_front()
	else:
		emit_signal("game_lost")
		
	if button_array.size() == 0:
		emit_signal("game_won")
