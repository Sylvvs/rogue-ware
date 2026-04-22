extends CanvasLayer

@onready var loss = $Loss
@onready var heart = $Loss/HBoxContainer/Heart
@onready var heart_container = $Loss/HBoxContainer

@onready var win = $Win
@onready var win_label = $Win/MarginContainer/HBoxContainer/RichTextLabel

@onready var timer = $Timer

var hearts = []
var max_normal_hp = 3
var current_hp = 3

var pending_damage = 0

func _ready():
	create_hearts()

func create_hearts():
	for i in range(max_normal_hp):
		var new_heart = heart.duplicate()
		new_heart.visible = true
		
		heart_container.add_child(new_heart)
		hearts.append(new_heart)

	heart.visible = false
	loss.visible = false
	win.visible = false

	update_hearts()

func update_hearts():
	for i in range(hearts.size()):
		set_heart_state(hearts[i], i < current_hp)

func set_heart_state(heart_node, filled: bool):
	if heart_node.texture is AtlasTexture:
		var tex = heart_node.texture
		tex = tex.duplicate()
		
		if filled:
			tex.region.position.x = 0
		else:
			tex.region.position.x = 22
		
		heart_node.texture = tex

func lose_heart(amount := 1):
	pending_damage += amount
	play_loss()

func gain_heart(amount := 1):
	current_hp = min(current_hp + amount, max_normal_hp)
	update_hearts()

func gain_max_hp(amount := 1):
	for i in range(amount):
		max_normal_hp += 1
		
		var new_heart = heart.duplicate()
		new_heart.visible = true
		
		if new_heart.texture is AtlasTexture:
			new_heart.texture = new_heart.texture.duplicate()
			new_heart.texture.region.position.x += 20
		
		heart_container.add_child(new_heart)
		hearts.append(new_heart)

	current_hp += amount
	update_hearts()



func play_loss():
	win.visible = false
	loss.visible = true
	timer.start()

func _on_timer_timeout() -> void:
	if pending_damage <= 0:
		return
	
	for i in range(pending_damage):
		if current_hp > 0:
			current_hp -= 1
			
			set_heart_state(hearts[current_hp], false)
	
	pending_damage = 0
	
	if current_hp <= 0:
		get_parent().die()

func play_win(start_value: int, add_value: int):
	loss.visible = false
	win.visible = true
	
	var duration = 2.0
	var steps = abs(add_value)
	
	if steps == 0:
		win_label.text = str(start_value)
		return
	
	var step_time = duration / steps
	
	var current_value = start_value
	win_label.text = str(current_value)

	count_up(current_value, add_value, step_time)

func count_up(value, remaining, step_time):
	if remaining == 0:
		return
	
	await get_tree().create_timer(step_time).timeout
	
	value += sign(remaining)*2
	remaining -= sign(remaining)*2
	
	win_label.text = str(value)
	
	count_up(value, remaining, step_time)
