extends Minigame

var instruction_text_value := "Memorize the number!"
var time_limit_value := 60

var level: int = 1
var current_number: String = ""
var show_time: float = 1.0

var label_number: Label
var label_instruction: Label
var input_field: LineEdit
var show_timer: Timer
var feedback_timer: Timer
var progress_bar: ProgressBar
var tween: Tween


func start() -> void:
	instruction_text = instruction_text_value
	time_limit = time_limit_value
	build_ui()
	next_level()

func build_ui() -> void:
	var label_round := Label.new()
	label_round.name = "LabelRound"
	label_round.position = Vector2(20, 10)
	label_round.size = Vector2(400, 35)
	label_round.add_theme_font_size_override("font_size", 22)
	add_child(label_round)

	label_instruction = Label.new()
	label_instruction.position = Vector2(0, 50)
	label_instruction.size = Vector2(1152, 60)
	label_instruction.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_instruction.add_theme_font_size_override("font_size", 30)
	add_child(label_instruction)

	# Progress bar just below instruction
	progress_bar = ProgressBar.new()
	progress_bar.position = Vector2(176, 115)
	progress_bar.size = Vector2(800, 20)
	progress_bar.min_value = 0.0
	progress_bar.max_value = 1.0
	progress_bar.value = 1.0
	progress_bar.show_percentage = false
	add_child(progress_bar)

	label_number = Label.new()
	label_number.position = Vector2(0, 200)
	label_number.size = Vector2(1152, 200)
	label_number.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_number.add_theme_font_size_override("font_size", 120)
	add_child(label_number)

	input_field = LineEdit.new()
	input_field.position = Vector2(376, 430)
	input_field.size = Vector2(400, 50)
	input_field.add_theme_font_size_override("font_size", 30)
	input_field.placeholder_text = "Type the number..."
	input_field.visible = false
	input_field.text_changed.connect(on_text_changed)
	add_child(input_field)

	show_timer = Timer.new()
	show_timer.one_shot = true
	show_timer.timeout.connect(on_show_timer_timeout)
	add_child(show_timer)

	feedback_timer = Timer.new()
	feedback_timer.wait_time = 1.0
	feedback_timer.one_shot = true
	feedback_timer.timeout.connect(on_feedback_timer_timeout)
	add_child(feedback_timer)

func next_level() -> void:
	current_number = str(randi_range(1, 9))
	for i in range(level - 1):
		current_number += str(randi_range(0, 9))

	label_number.text = current_number
	label_number.add_theme_color_override("font_color", Color(1, 1, 1))
	label_instruction.text = "Level %d — Memorize!" % level
	input_field.visible = false
	input_field.text = ""

	var round_label := get_node_or_null("LabelRound") as Label
	if round_label:
		round_label.text = "Level: %d/7" % level

	show_time = clamp(float(level) * 0.8, 1.0, 2.0)
	progress_bar.value = 1.0
	progress_bar.visible = true

	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(progress_bar, "value", 0.0, show_time)

	show_timer.wait_time = show_time
	show_timer.start()

func on_show_timer_timeout() -> void:
	progress_bar.visible = false
	label_number.text = "?"
	label_instruction.text = "What was the number?"
	input_field.visible = true
	input_field.text = ""
	input_field.grab_focus()

func on_text_changed(new_text: String) -> void:
	if new_text.length() < current_number.length():
		return
	if new_text == current_number:
		label_number.text = current_number
		label_number.add_theme_color_override("font_color", Color(0.2, 0.9, 0.2))
		label_instruction.text = "✓ Correct! Level %d" % level
		input_field.visible = false
		level += 1
		feedback_timer.start()
	else:
		label_number.text = current_number
		label_number.add_theme_color_override("font_color", Color(0.9, 0.2, 0.2))
		label_instruction.text = "✗ Wrong! It was %s" % current_number
		input_field.visible = false
		feedback_timer.start()

func on_feedback_timer_timeout() -> void:
	if label_instruction.text.begins_with("✗"):
		emit_signal("game_lost")
	elif level > 7:
		emit_signal("game_won")
	else:
		next_level()
