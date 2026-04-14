extends Control

@onready var bomb = $Bomb
@onready var timer = $Timer
@onready var timeShow = $Time
@onready var desc = $Label/Description
@onready var skip = $Label/Skip

@onready var bombStringPart = $Bomb/BombStringPart
@onready var bombStringStart = $Bomb/BombStringStart
@onready var fuseHolder = $Bomb/FuseHolder
@onready var bombFuse = $Bomb/FuseHolder/BombFuse
@onready var explosionHolder = $Bomb/ExplosionHolder
@onready var explosion = $Bomb/ExplosionHolder/Explosion

signal time_out
signal skipping

var time = 5
var init_time = 5

func start():
	timer.start()
	timeShow.text = str(time)
	_handle_color()
	_handle_skip_button()

	bombStringPart.hide()

	for i in range(time - 2):
		var newPart = bombStringPart.duplicate()
		newPart.show()
		newPart.name = "BombStringPart%d" % i
		bomb.add_child(newPart)

	# keep fuse last
	bomb.move_child(fuseHolder, bomb.get_child_count() - 1)

func change_text(param: String):
	desc.text = param

func _on_timer_timeout():
	time -= 1
	timeShow.text = str(time)
	_handle_color()
	
	if time <= 0:
		bomb.move_child(explosionHolder, bomb.get_child_count() - 1)
		explosion.position.y = -200
		explosion.position.x = -100
		explosion.visible = true
		if time < 0:
			emit_signal("time_out")

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

func _handle_color():
	if time > init_time:
		timeShow.text = "[color=cyan]" + timeShow.text + "[/color]"

func _handle_skip_button():
	skip.visible = false
	if Inventory.consume_active("skip_minigame"):
		skip.visible = true

func _on_skip_pressed() -> void:
	emit_signal("skipping")
