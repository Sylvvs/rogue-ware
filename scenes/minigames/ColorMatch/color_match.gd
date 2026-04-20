extends Minigame

var instruction_text_value := "Click the COLOR of the word, not what it says!"
var time_limit_value := 20
var win_condition = 5

const COLORS = {
	"Red":     Color(0.95, 0.15, 0.15),
	"Blue":    Color(0.15, 0.4,  1.0),
	"Green":   Color(0.1,  0.8,  0.1),
	"Yellow":  Color(1.0,  0.9,  0.0),
	"Purple":  Color(0.6,  0.1,  0.9),
	"Orange":  Color(1.0,  0.5,  0.0),
	"Pink":    Color(1.0,  0.4,  0.7),
	"Cyan":    Color(0.0,  0.85, 0.9),
	"White":   Color(1.0,  1.0,  1.0),
	"Brown":   Color(0.6,  0.3,  0.1),
	"Lime":    Color(0.6,  1.0,  0.0),
	"Magenta": Color(0.9,  0.0,  0.8),
}

var _score: int = 0
var _word: String = ""
var _word_color: String = ""
var _pending_result: String = ""  

var _label_word: RichTextLabel
var _label_score: Label
var _feedback_timer: Timer
var _buttons: Array = []

func start() -> void:
	instruction_text = instruction_text_value
	time_limit = time_limit_value 
	win_condition = clamp(ceili(win_condition * mult),5,15)
	time_limit += ceil(win_condition * 0.3)
	_build_ui()
	_next_round()


func _build_ui() -> void:
	_label_score = Label.new()
	_label_score.position = Vector2(20, 10)
	_label_score.size = Vector2(400, 35)
	_label_score.add_theme_font_size_override("font_size", 22)
	add_child(_label_score)

	_label_word = RichTextLabel.new()
	_label_word.position = Vector2(276, 80)
	_label_word.size = Vector2(600, 120)
	_label_word.bbcode_enabled = true
	_label_word.fit_content = false
	_label_word.scroll_active = false
	_label_word.add_theme_font_size_override("normal_font_size", 90)
	add_child(_label_word)

	var color_names: Array = COLORS.keys()
	var btn_w := 220
	var btn_h := 55
	var cols := 4
	var gap_x := 15
	var gap_y := 12
	var total_w := cols * btn_w + (cols - 1) * gap_x
	var start_x: float = (1152.0 - total_w) / 2.0
	var start_y := 230

	for i in range(color_names.size()):
		var btn := Button.new()
		var col := i % cols
		var row: int = i / cols
		btn.position = Vector2(start_x + col * (btn_w + gap_x), start_y + row * (btn_h + gap_y))
		btn.size = Vector2(btn_w, btn_h)
		btn.text = color_names[i]
		btn.add_theme_font_size_override("font_size", 24)
		btn.add_theme_color_override("font_color", COLORS[color_names[i]])
		btn.pressed.connect(_on_button_pressed.bind(color_names[i]))
		add_child(btn)
		_buttons.append(btn)

	_feedback_timer = Timer.new()
	_feedback_timer.wait_time = 0.6
	_feedback_timer.one_shot = true
	_feedback_timer.timeout.connect(_on_feedback_timer_timeout)
	add_child(_feedback_timer)

func _next_round() -> void:
	_pending_result = ""
	var color_names: Array = COLORS.keys()

	_word = color_names[randi() % color_names.size()]
	var other_colors: Array = color_names.filter(func(c): return c != _word)
	_word_color = other_colors[randi() % other_colors.size()]

	var hex: String = COLORS[_word_color].to_html(false)
	_label_word.text = "[center][color=#%s]%s[/color][/center]" % [hex, _word]
	_label_score.text = "Score: " + JSON.stringify(_score) + "/" + JSON.stringify(win_condition)

	for btn in _buttons:
		btn.disabled = false

func _on_button_pressed(chosen: String) -> void:
	for btn in _buttons:
		btn.disabled = true

	if chosen == _word_color:
		_score += 1
		_label_score.text = "Score: " + JSON.stringify(_score) + "/" + JSON.stringify(win_condition)
		_label_word.text = "[center][color=#33ee33]✓ Correct![/color][/center]"
		if _score >= win_condition:
			_pending_result = "won"
		else:
			_pending_result = "next"
	else:
		_label_word.text = "[center][color=#ee3333]✗ Wrong![/color][/center]"
		_pending_result = "lost"

	_feedback_timer.start()

func _on_feedback_timer_timeout() -> void:
	if _pending_result == "won":
		emit_signal("game_won")
	elif _pending_result == "lost":
		emit_signal("game_lost")
	else:
		_next_round()
