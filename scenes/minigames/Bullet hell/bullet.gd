extends Area2D
var bullet_direction = Vector2()
var lifetime: float
var hitbox_timer = 0.0
const hitbox_delay = 0.5

func _ready() -> void:
	if has_node("BeamCollision"):
		$BeamCollision.disabled = true
func _process(delta):
	position += bullet_direction * delta
	lifetime -= delta
	if lifetime < 0:
		queue_free()

	if hitbox_timer < hitbox_delay:
		hitbox_timer += delta
		if hitbox_timer >= hitbox_delay:
			if has_node("BeamCollision"):
				$BeamCollision.disabled = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group('player'):
		if body.invincible:
			return
		body.health -= 1
		body.invincible = true
		body.invincible_timer = 0.0
		var player = get_tree().get_first_node_in_group('player')
		player.play_anim('Hit')
