extends Minigame

var MAX_ROUNDS := 3

const COLOR_DEFAULT   := Color(0.0, 0.0, 0.0, 1.0)
const COLOR_HIGHLIGHT := Color(1.0, 0.78, 0.0,  1.0)
const SHADER_PATH     := "res://scenes/minigames/EuropeLocator/country.gdshader"

const COUNTRIES = {
	"de": "Germany",     "fr": "France",      "es": "Spain",       "it": "Italy",
	"pl": "Poland",      "se": "Sweden",      "no": "Norway",      "fi": "Finland",
	"dk": "Denmark",     "nl": "Netherlands", "be": "Belgium",     "at": "Austria",
	"ch": "Switzerland", "pt": "Portugal",    "gr": "Greece",      "ro": "Romania",
	"hu": "Hungary",     "cz": "Czech",       "sk": "Slovakia",    "hr": "Croatia",
	"gb": "United Kingdom", "ua": "Ukraine",  "by": "Belarus",
	"lt": "Lithuania",   "lv": "Latvia",      "ee": "Estonia",     "rs": "Serbia",
	"ba": "Bosnia",      "al": "Albania",     "bg": "Bulgaria",    "si": "Slovenia",
	"ie": "Ireland",     "is": "Iceland",     "lu": "Luxembourg",  "md": "Moldova",
	"me": "Montenegro",  "mk": "North Macedonia", "ru": "Russia",
}

var round_countries: Array = []
var current_code: String = ""
var current_name: String = ""
var score: int = 0
var round_index: int = 0

var input_field: LineEdit
var label_score: Label
var label_feedback: Label
var feedback_timer: Timer


func start() -> void:
	instruction_text = "Type the name of the highlighted country!"
	time_limit = 60
	MAX_ROUNDS = clamp(ceil(MAX_ROUNDS * mult),3,10)
	_build_ui()
	_setup_shaders()
	_pick_round_countries()
	_next_round()

func _setup_shaders() -> void:
	var shader: Shader = load(SHADER_PATH)
	for code in COUNTRIES.keys():
		var node := get_node_or_null(code) as Sprite2D
		if node:
			var mat := ShaderMaterial.new()
			mat.shader = shader
			mat.set_shader_parameter("tint_color", COLOR_DEFAULT)
			node.material = mat

func _set_color(code: String, color: Color) -> void:
	var node := get_node_or_null(code) as Sprite2D
	if node and node.material:
		(node.material as ShaderMaterial).set_shader_parameter("tint_color", color)


var hint_button: Button
var label_hint: Label

func _build_ui() -> void:
	label_score = Label.new()
	label_score.position = Vector2(20, 8)
	label_score.size = Vector2(500, 30)
	label_score.add_theme_font_size_override("font_size", 20)
	add_child(label_score)

	input_field = LineEdit.new()
	input_field.position = Vector2(725, 500)
	input_field.size = Vector2(400, 34)
	input_field.add_theme_font_size_override("font_size", 22)
	input_field.placeholder_text = "Type the country name..."
	input_field.text_changed.connect(_on_input_field_text_changed)
	add_child(input_field)

	hint_button = Button.new()
	hint_button.position = Vector2(725, 463)
	hint_button.size = Vector2(80, 28)
	hint_button.text = "Hint"
	hint_button.add_theme_font_size_override("font_size", 18)
	hint_button.pressed.connect(_on_hint_pressed)
	add_child(hint_button)

	label_hint = Label.new()
	label_hint.position = Vector2(810, 463)
	label_hint.size = Vector2(200, 28)
	label_hint.add_theme_font_size_override("font_size", 20)
	add_child(label_hint)

	label_feedback = Label.new()
	label_feedback.position = Vector2(1015, 465)
	label_feedback.size = Vector2(500, 34)
	label_feedback.add_theme_font_size_override("font_size", 22)
	add_child(label_feedback)

	feedback_timer = Timer.new()
	feedback_timer.wait_time = 1.2
	feedback_timer.one_shot = true
	feedback_timer.timeout.connect(_on_feedback_timer_timeout)
	add_child(feedback_timer)

func _pick_round_countries() -> void:
	var all: Array = COUNTRIES.keys().duplicate()
	all.shuffle()
	round_countries = all.slice(0, MAX_ROUNDS)

func _next_round() -> void:
	if round_index >= MAX_ROUNDS:
		_finish()
		return

	for code in COUNTRIES.keys():
		_set_color(code, COLOR_DEFAULT)

	current_code = round_countries[round_index]
	current_name = COUNTRIES[current_code]
	_set_color(current_code, COLOR_HIGHLIGHT)

	label_score.text = "Score: %d  Round: %d/%d" % [score, round_index + 1, MAX_ROUNDS]
	label_feedback.text = ""
	label_hint.text = ""
	hint_button.disabled = false
	input_field.text = ""
	input_field.grab_focus()

func _on_hint_pressed() -> void:
	label_hint.text = current_code.to_upper()
	hint_button.disabled = true

func _on_input_field_text_changed(new_text: String) -> void:
	if current_name == "":
		return
	if new_text.strip_edges().to_lower() == current_name.to_lower():
		_handle_correct()

func _handle_correct() -> void:
	score += 1
	round_index += 1
	label_score.text = "Score: %d  Round: %d/%d" % [score, round_index, MAX_ROUNDS]
	label_feedback.text = "✓ Correct!"
	label_feedback.add_theme_color_override("font_color", Color(0.2, 0.9, 0.2))
	current_name = ""
	feedback_timer.start()

func _on_feedback_timer_timeout() -> void:
	_next_round()

func _finish() -> void:
	for code in COUNTRIES.keys():
		_set_color(code, COLOR_DEFAULT)
	label_feedback.text = ""
	label_score.text = "Score: %d/%d" % [score, MAX_ROUNDS]
	if score >= MAX_ROUNDS / 2.0:
		emit_signal("game_won")
	else:
		emit_signal("game_lost")
