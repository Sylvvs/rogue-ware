extends Minigame

const MAP_PIECES = [
	preload("res://scenes/minigames/Platformer/level.tscn"),
	preload("res://scenes/minigames/Platformer/test_leve.tscn")
]

var piece_count = 3
var last_index = -1
var piece_spacing = Vector2(648,0)


func start():
	time_limit = 25
	instruction_text = "Get to the far right side as fast as possible"
	
	generate_map()
	pass

func generate_map():
	
	for i in range(piece_count):
		var piece = load_random_piece()
		if piece == null:
			continue
		
		piece.position = piece_spacing * i
		add_child(piece)
	
	
func load_random_piece():
	var index = randi() % MAP_PIECES.size()
	while index == last_index and MAP_PIECES.size() > 1:
		index = randi() % MAP_PIECES.size()
	last_index = index
	return MAP_PIECES[index].instantiate()
