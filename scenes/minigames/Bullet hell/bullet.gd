extends Area2D
var bullet_direction = Vector2()

func _process(delta):
	position += bullet_direction * delta
	pass


func _on_body_entered(body: CharacterBody2D) -> void:
	if body.name == "BulletHellGuy":
		print("guy hit!")
