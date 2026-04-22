extends Control


func _on_general_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/Tutorials/general_tutorial_screen.tscn")
	pass # Replace with function body.


func _on_platformer_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/Tutorials/platformer_tutorial.tscn")
	pass # Replace with function body.


func _on_bullethell_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/Tutorials/bullethell_tutorial.tscn")
	pass # Replace with function body.


func _on_rhythia_pressed() -> void:
	pass # Replace with function body.


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/StartScreen/start_screen.tscn")
	pass # Replace with function body.
