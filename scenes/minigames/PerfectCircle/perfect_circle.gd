extends Minigame

var points = []
var drawing = false

@onready var point_holder = $PointHolder
@onready var label = $Label

func start():
	time_limit = 10
	instruction_text = "Draw a good circle!"
	point_holder.gui_input.connect(_on_point_holder_gui_input)
	point_holder.draw.connect(_holder_draw)

func _on_point_holder_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			points.clear()
			drawing = true
		else:
			drawing = false
			evaluate_circle()

	elif event is InputEventMouseMotion and drawing:
		points.append(event.position)
		point_holder.queue_redraw()

func _holder_draw():
	for i in range(points.size() - 1):
		point_holder.draw_line(points[i], points[i+1], Color.WHITE, 3)

func get_center():
	var sum = Vector2.ZERO
	for p in points:
		sum += p
	return sum / points.size()

func get_radius(center):
	var total = 0.0
	for p in points:
		total += p.distance_to(center)
	return total / points.size()


func evaluate_circle():
	var center = get_center()
	var radius = get_radius(center)
	
	if radius < 50 or points.size() < 5:
		label.text = "Too small!"
		return
	
	var error = 0.0
	var deviance = 0.0
	for p in points:
		var dist = p.distance_to(center)
		error += abs(dist - radius)
		if dist > deviance:
			deviance = dist
	
	error /= points.size()
	var score = deviance/(2*radius)
	#print(score)
	
	if score > 0.65:
		label.text = "Not good enough!"
	if score <= 0.65:
		emit_signal("game_won")
	
