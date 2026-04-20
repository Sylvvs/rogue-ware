extends Minigame

var clicks = 0
var win_condition = 25
var difficulty = 1

@onready var win_label = $winLabel
@export var button_scene: PackedScene

func start():
	win_condition = clamp(ceili(win_condition * 1/2 * mult),12,50)
	instruction_text = "Click as fast as you can"
	time_limit = 7
	win_label.text = "Number of clicks to win: " + str(win_condition)
	$Timer.wait_time = 0.2
	$Timer.start()

func _on_timer_timeout():
	spawn_button()
	
func spawn_button():
	var button = button_scene.instantiate()
	button.position = Vector2(randf_range(0, 1152), -20)
	add_child(button)
	
func _on_red_button_pressed() -> void:
	clicks += 1
	win_label.text = "Number of clicks to win: " + str(win_condition - clicks)
	if clicks > win_condition-1:
		emit_signal("game_won")
