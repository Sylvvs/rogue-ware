extends Node2D

var speed: float = 0.0

func _process(delta: float) -> void:
	position.x += speed * delta
