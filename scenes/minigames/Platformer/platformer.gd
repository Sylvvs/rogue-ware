extends Minigame
@onready var player = $Player
const MAP_PIECES = [
	preload("res://scenes/minigames/Platformer/level.tscn"),
	preload("res://scenes/minigames/Platformer/test_leve.tscn"),
	preload("res://scenes/minigames/Platformer/Level 2.tscn"),
	preload("res://scenes/minigames/Platformer/Level 3.tscn"),
	preload("res://scenes/minigames/Platformer/Level 4.tscn"),
	preload("res://scenes/minigames/Platformer/Level 5.tscn"),
	preload("res://scenes/minigames/Platformer/Level 6.tscn")
]
@onready var win_condition = $Wincondition
var piece_count = 3
var last_index = -1
var piece_spacing = Vector2(648,200)
var win_condition_monitoring


func start():
	time_limit = 180
	instruction_text = "Get to the far right side as fast as possible"
	piece_count = clamp(ceil(piece_count * mult),3,10)
	player.speed.connect(lost)
	generate_map()
	pass

func generate_map():
	win_condition_monitoring = false
	var prevPos = Vector2(0,0)
	for i in range(piece_count):
		var piece = load_random_piece()
		if piece == null:
			continue
		
		add_child(piece)
		var startMarker = piece.get_node("Start")
		var end = piece.get_node("End")
		
		piece.global_position += prevPos - startMarker.global_position
		

		print("Spawned at " + JSON.stringify(prevPos))
		prevPos = end.global_position
		if i == piece_count-1:
			win_condition.position = end.global_position
			print(win_condition.position)
	win_condition_monitoring = true
	
	
func load_random_piece():
	var index = randi() % MAP_PIECES.size()
	while index == last_index and MAP_PIECES.size() > 1:
		index = randi() % MAP_PIECES.size()
	last_index = index
	return MAP_PIECES[index].instantiate()


func _on_wincondition_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	
	emit_signal("game_won")

func lost():
	emit_signal("game_lost")
