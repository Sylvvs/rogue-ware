extends Node2D


@onready var fake_mouse = $"../FakeMouse"
@export var note_scene: PackedScene
@export var approach_duration = 1.0
@export var song_path = "res://music/TVWorld/TVWorld"
const grid_cols = 3
const  grid_rows = 3
const cell_size = 145
const grid_offset = Vector2(370, 75)


var map = []
var next_note_index = 0
func grid_to_screen(col, row) -> Vector2:
	return grid_offset + Vector2(col * cell_size + cell_size / 2, row * cell_size + cell_size / 2)

func _ready():
	draw_grid()
	const filePath = "res://scenes/minigames/Rhytia/Maps/"
	var song = get_parent().song
	var songPath = filePath + song + ".json" 
	var file = FileAccess.open(songPath, FileAccess.READ)
	var json = JSON.new()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	json.parse(file.get_as_text())
	map = json.get_data()
	map.sort_custom(func(a, b): return a.time < b.time)
	Conductor.total_notes = map.size()

func draw_grid():
	for row in range(grid_rows):
		for col in range(grid_cols):
			var marker = Panel.new()
			marker.size = Vector2(cell_size, cell_size)
			var center = grid_to_screen(col, row)
			marker.position = center - marker.size / 2
			var style = StyleBoxFlat.new()
			style.bg_color = Color(0, 0, 0, 0)
			style.border_color = Color(1, 1, 1, 0.65)
			style.border_width_left = 2 if col == 0 else 0
			style.border_width_right = 2 if col == grid_cols - 1 else 0
			style.border_width_top = 2 if row == 0 else 0
			style.border_width_bottom = 2 if row == grid_rows - 1 else 0
			marker.add_theme_stylebox_override("panel", style)
			add_child(marker)

func _process(delta):
	if not Conductor.is_playing:
		return
	
	update_fake_cursor()
	while next_note_index < map.size():
		var note_data = map[next_note_index]
		if Conductor.current_time >= note_data.time - approach_duration:
			spawn_note(note_data)
			next_note_index += 1
		else:
			break

func spawn_note(note_data: Dictionary):
	var note = note_scene.instantiate()
	add_child(note)
	note.position = grid_to_screen(note_data.col, note_data.row)
	note.target_position = grid_to_screen(note_data.col, note_data.row)
	note.hit_time = note_data.time
	note.approach_duration = approach_duration
	note.scale = Vector2(0.1, 0.1)

func update_fake_cursor():
	var mouse_pos = get_global_mouse_position()
	var min_pos = grid_offset
	var max_pos = grid_offset + Vector2(grid_cols * cell_size, grid_rows * cell_size)
	
	mouse_pos.x = clamp(mouse_pos.x, min_pos.x, max_pos.x - 1)
	mouse_pos.y = clamp(mouse_pos.y, min_pos.y, max_pos.y -1)
	
	fake_mouse.global_position = mouse_pos
