extends Area2D

var speed = 200.0

func _physics_process(delta: float) -> void:
	position.y += speed * delta
	rotation_degrees += 5
	


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group('player'):
		queue_free()
	pass
