extends Minigame

var points = []
var drawing = false

@onready var point_holder = $PointHolder
@onready var label = $Label

func start():
	time_limit = 20
	time_limit = clamp(ceil(time_limit - (2 * mult)),5,180)
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
	
	if points.size() < 20:
		label.text = "Draw more!"
		return
	if radius < 50:
		label.text = "Too small!"
		return
	
	var gap = points[0].distance_to(points[-1])
	if gap > radius * 0.8:
		label.text = "Close the circle!"
		return
	
	var variance = 0.0
	for p in points:
		var diff = p.distance_to(center) - radius
		variance += diff * diff
	variance /= points.size()
	var std_dev = sqrt(variance)
	var score = std_dev / radius 
	
	var percent = int((1.0 - clamp(score / 0.3, 0.0, 1.0)) * 150)
	label.text = "%d%%" % percent
	
	if score < 0.12:
		emit_signal("game_won")
	else:
		label.text = label.text + "\nNot round enough!"
