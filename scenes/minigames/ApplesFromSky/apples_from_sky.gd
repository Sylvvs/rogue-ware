extends Minigame

@export var apple_scene: PackedScene
var screen_width

func start():
	instruction_text = "Catch the apples!"
	time_limit = 20
	
	get_tree().root.connect("size_changed", _on_screen_resized)
	
	screen_width = get_viewport().size.x
	print(screen_width)
	$Timer.wait_time = 2
	$Timer.start()

func _on_timer_timeout():
	spawn_apple()
	
func spawn_apple():
	var apple = apple_scene.instantiate()
	apple.position = Vector2(randf_range(0, 1152), -20)
	add_child(apple)
	
func _on_screen_resized():
	screen_width = get_viewport().size.x
func stop():
	emit_signal("game_won")

func _on_area_2d_area_entered(area: Area2D) -> void:
	emit_signal("game_lost")
	pass # Replace with function body.
