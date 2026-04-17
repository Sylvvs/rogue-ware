extends Minigame

var clicks = 0
var win_condition = 25
var difficulty = 1

@onready var win_label = $winLabel

func start():
	win_condition = ceil(win_condition * 1/2 * mult)
	instruction_text = "Click as fast as you can"
	time_limit = 7
	win_label.text = "Number of clicks to win: " + str(win_condition)


func _on_red_button_pressed() -> void:
	clicks += 1
	win_label.text = "Number of clicks to win: " + str(win_condition - clicks)
	if clicks > win_condition-1:
		emit_signal("game_won")
