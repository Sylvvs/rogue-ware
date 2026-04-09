extends Area2D
var bullet_direction = Vector2()


func _process(delta):
	position += bullet_direction * delta
	pass


func _on_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group('player'):
		body.health -= 1
		var player = get_tree().get_first_node_in_group('player')
		player.play_anim('Hit')
		print("guy hit!", body.health)
