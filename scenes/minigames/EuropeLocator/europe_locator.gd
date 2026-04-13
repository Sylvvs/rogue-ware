extends Minigame

const MAX_ROUNDS := 10

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

var _round_countries: Array = []
var _current_code: String = ""
var _current_name: String = ""
var _score: int = 0
var _round_index: int = 0

var _input_field: LineEdit
var _label_score: Label
var _label_feedback: Label
var _feedback_timer: Timer

func _ready() -> void:
	start()

func start() -> void:
	instruction_text = "Type the name of the highlighted country!"
	time_limit = 60
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

func stop() -> void:
	pass

func _build_ui() -> void:
	_label_score = Label.new()
	_label_score.position = Vector2(20, 8)
	_label_score.size = Vector2(500, 30)
	_label_score.add_theme_font_size_override("font_size", 20)
	add_child(_label_score)

	_input_field = LineEdit.new()
	_input_field.position = Vector2(725, 500)
	_input_field.size = Vector2(400, 34)
	_input_field.add_theme_font_size_override("font_size", 22)
	_input_field.placeholder_text = "Type the country name..."
	_input_field.text_changed.connect(_on_input_field_text_changed)
	add_child(_input_field)

	_label_feedback = Label.new()
	_label_feedback.position = Vector2(725, 465)
	_label_feedback.size = Vector2(380, 34)
	_label_feedback.add_theme_font_size_override("font_size", 22)
	add_child(_label_feedback)

	_feedback_timer = Timer.new()
	_feedback_timer.wait_time = 1.2
	_feedback_timer.one_shot = true
	_feedback_timer.timeout.connect(_on_feedback_timer_timeout)
	add_child(_feedback_timer)

func _pick_round_countries() -> void:
	var all: Array = COUNTRIES.keys().duplicate()
	all.shuffle()
	_round_countries = all.slice(0, MAX_ROUNDS)

func _next_round() -> void:
	if _round_index >= MAX_ROUNDS:
		_finish()
		return

	for code in COUNTRIES.keys():
		_set_color(code, COLOR_DEFAULT)

	_current_code = _round_countries[_round_index]
	_current_name = COUNTRIES[_current_code]
	_set_color(_current_code, COLOR_HIGHLIGHT)

	_label_score.text = "Score: %d  Round: %d/%d" % [_score, _round_index + 1, MAX_ROUNDS]
	_label_feedback.text = ""
	_input_field.text = ""
	_input_field.grab_focus()

func _on_input_field_text_changed(new_text: String) -> void:
	if _current_name == "":
		return
	if new_text.strip_edges().to_lower() == _current_name.to_lower():
		_handle_correct()

func _handle_correct() -> void:
	_score += 1
	_round_index += 1
	_label_score.text = "Score: %d  Round: %d/%d" % [_score, _round_index, MAX_ROUNDS]
	_label_feedback.text = "✓ Correct!"
	_label_feedback.add_theme_color_override("font_color", Color(0.2, 0.9, 0.2))
	_current_name = ""
	_feedback_timer.start()

func _on_feedback_timer_timeout() -> void:
	_next_round()

func _finish() -> void:
	for code in COUNTRIES.keys():
		_set_color(code, COLOR_DEFAULT)
	_label_feedback.text = ""
	_label_score.text = "Score: %d/%d" % [_score, MAX_ROUNDS]
	if _score >= MAX_ROUNDS / 2.0:
		emit_signal("game_won")
	else:
		emit_signal("game_lost")
