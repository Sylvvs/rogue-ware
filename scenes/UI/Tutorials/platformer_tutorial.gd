extends Node2D


func _on_area_2d_body_entered(body: Node2D) -> void:
	body.position = Vector2(137,566)
	pass # Replace with function body.


func _on_area_2d_2_body_entered(body: Node2D) -> void:
	if body.is_in_group('player'):
		get_tree().change_scene_to_file("res://scenes/UI/Tutorials/tutorial_screen.tscn")
	pass # Replace with function body.
