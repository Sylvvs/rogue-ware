extends Minigame

@onready var label = $Label
@onready var cursor = $Cursor

const WORDS = ["time","person","year","way","day","thing","man","world","life","hand",
"part","child","eye","woman","place","work","week","case","point","government",
"company","number","group","problem","fact","be","have","do","say","get",
"make","go","know","take","see","come","think","look","want","give",
"use","find","tell","ask","seem","feel","try","leave","call","good",
"new","first","last","long","great","little","own","other","old","right",
"big","high","different","small","large","next","early","young","important","few",
"public","bad","same","able","happy","quick","slow","bright","run","walk",
"eat","drink","sleep","read","write","build","open","close","play","move",
"bring","start","stop","learn","change","create","watch","listen","speak","travel"]

var cursor_visible: bool = true
var cursor_timer: float = 0.0
const CURSOR_BLINK_RATE: float = 0.5

var words: String = ""
var progress: int = 0

func start():
	instruction_text = "Type the words!"
	time_limit = 20
	time_limit = clamp(ceil(time_limit - (4 * mult)),8,180)
	
	var word_amount = clamp(ceili(10 * mult),10,50)
	for i in range(word_amount):
		words = words + WORDS.pick_random() + " "
	words = words.trim_suffix(" ")
	update_label()
	

func _process(delta: float) -> void:
	cursor_timer += delta
	if cursor_timer >= CURSOR_BLINK_RATE:
		cursor_timer = 0.0
		cursor_visible = !cursor_visible
		cursor.visible = cursor_visible

func update_label():
	var typed = words.substr(0, progress)
	var remaining = words.substr(progress)
	label.text = "[color=#ffffff]" + typed + "[/color][color=#4f4f4f]" + remaining + "[/color]"
	
	await get_tree().process_frame
	update_cursor()

func update_cursor():
	var font = label.get_theme_font("normal_font")
	var font_size = label.get_theme_font_size("normal_font_size")
	
	var current_line = label.get_character_line(progress)
	var line_y = label.get_line_offset(current_line)
	var line_start = label.get_line_range(current_line)[0]
	var typed_on_line = words.substr(line_start, progress - line_start)
	var typed_width = font.get_string_size(typed_on_line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	
	cursor.position.x = label.position.x + typed_width
	cursor.position.y = label.position.y + line_y + 4
	cursor.size = Vector2(2, font_size * 1.2)

func _unhandled_key_input(event: InputEvent) -> void:

	if event.pressed and char(event.unicode) == words[progress]:
		progress += 1
	update_label()
	
	if progress == words.length():
		emit_signal("game_won")
