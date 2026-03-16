extends Minigame

@onready var label = $Label

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

var words: String = ""
var progress: int = 0

func start():
	instruction_text = "Type the words!"
	time_limit = 10
	
	for i in range(10):
		words = words + WORDS.pick_random() + " "
	words = words.trim_suffix(" ")
	label.text = "[color=#4f4f4f]" + words + "[/color]"

func _unhandled_key_input(event: InputEvent) -> void:
	if event.pressed and char(event.unicode) == words[progress]:
		progress += 1
	label.text = "[color=#ffffff]" + words.substr(0,progress) + "[/color]"
	label.text = label.text + "[color=#4f4f4f]" + words.substr(progress) + "[/color]"
	
	if progress == words.length():
		emit_signal("game_won")
