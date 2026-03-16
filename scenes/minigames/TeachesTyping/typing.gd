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

func start():
	instruction_text = "Type the words!"
	time_limit = 10
	
	for i in range(10):
		words = words + WORDS.pick_random() + " "
	words = words.trim_suffix(" ")
	print(words)
	label.text = words
	
