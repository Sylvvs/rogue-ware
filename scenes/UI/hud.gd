extends Control

@onready var bomb = $Bomb
@onready var timer = $Timer
@onready var timeShow = $Time

@onready var bombStringPart = $Bomb/BombStringPart
@onready var bombStringStart = $Bomb/BombStringStart
@onready var fuseHolder = $Bomb/FuseHolder
@onready var bombFuse = $Bomb/FuseHolder/BombFuse
@onready var explosionHolder = $Bomb/explosionHolder
@onready var explosion = $Bomb/ExplosionHolder/Explosion

var time = 5

func _ready():
	timer.start()
	timeShow.text = str(time)

	bombStringPart.hide()

	for i in range(time - 2):
		var newPart = bombStringPart.duplicate()
		newPart.show()
		newPart.name = "BombStringPart%d" % i
		bomb.add_child(newPart)

	# keep fuse last
	bomb.move_child(fuseHolder, bomb.get_child_count() - 1)


func _on_timer_timeout():
	time -= 1
	timeShow.text = str(time)
	
	if time <= 0:
		bomb.move_child(explosionHolder, bomb.get_child_count() - 1)
		explosion.position.y = -200
		explosion.position.x = -100
		explosion.visible = true

	var removed := false

	for child in bomb.get_children():
		if child == bombStringPart:
			continue

		if child.name.begins_with("BombStringPart"):
			child.queue_free()
			removed = true
			break

	if !removed:
		bombStringStart.hide()

	if time == 1:
		bombFuse.position.y = -75
	else:
		bombFuse.position.y = 0

var flicker = true

func _on_flicker_timer_timeout() -> void:
	if flicker:
		bombFuse.texture.region.position.y = 42
	else:
		bombFuse.texture.region.position.y = 26
	flicker = !flicker
