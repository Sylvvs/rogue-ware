extends Node2D

@export var note_scene: PackedScene
@export var approach_duration = 1.0

const grid_cols = 3
const  grid_rows = 3
const cell_size = 120
const grid_offset = Vector2(100, 50)

var map = []
var next_note_index = 0
func grid_to_screen(col, row) -> Vector2:
	return grid_offset + Vector2(col * cell_size + cell_size / 2, row * cell_size + cell_size / 2)

func _ready():
	draw_grid()
	var file = FileAccess.open("res://scenes/minigames/Rhytia/Maps/testmap.json", FileAccess.READ)
	var json = JSON.new()
	json.parse(file.get_as_text())
	map = json.get_data()
	Conductor.start(load("res://music/RudeBuster/RudeBuster.mp3"))
	map.sort_custom(func(a, b): return a.time < b.time)

func draw_grid():
	for row in range(grid_rows):
		for col in range(grid_cols):
			var marker = ColorRect.new()
			marker.size = Vector2(cell_size, cell_size)
			var center = grid_to_screen(col, row)
			marker.position = center - marker.size / 2
			marker.color = Color(0.2, 0.2, 0.2, 0.2)
			add_child(marker)

func _process(delta):
	if not Conductor.is_playing:
		return
	# Spawn any notes that are due
	while next_note_index < map.size():
		var note_data = map[next_note_index]
		if Conductor.current_time >= note_data.time - approach_duration:
			spawn_note(note_data)
			next_note_index += 1
		else:
			break  # notes are sorted so no point checking further

func spawn_note(note_data: Dictionary):
	var note = note_scene.instantiate()
	add_child(note)
	note.position = grid_to_screen(note_data.col, note_data.row)
	note.target_position = grid_to_screen(note_data.col, note_data.row)
	note.hit_time = note_data.time
	note.approach_duration = approach_duration
	note.scale = Vector2(0.1, 0.1)
