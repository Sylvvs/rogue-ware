extends Area2D

var speed = 200

func _physics_process(delta: float) -> void:
	position.y += speed * delta
	rotation += 0.2
