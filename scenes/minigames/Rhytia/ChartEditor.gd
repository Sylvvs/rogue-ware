extends Control

const GRID_COLS = 3
const GRID_ROWS = 3

var notes: Array = []
var selected_cell: Vector2i = Vector2i(-1, -1)
var bpm: float = 120.0
var zoom: float = 160.0
var song_duration: float = 60.0
var is_playing: bool = false
var play_time: float = 0.0
var map_path: String = ""

@onready var grid_container: GridContainer = $HBox/LeftPanel/GridContainer
@onready var timeline: Control = $HBox/RightPanel/TimelineScroll/Timeline
@onready var timeline_scroll: ScrollContainer = $HBox/RightPanel/TimelineScroll
@onready var playhead: Panel = $HBox/RightPanel/TimelineScroll/Timeline/Playhead
@onready var bpm_spin: SpinBox = $TopBar/BPMSpin
@onready var zoom_slider: HSlider = $TopBar/ZoomSlider
@onready var time_label: Label = $BottomBar/TimeLabel
@onready var time_stamp: SpinBox = $TopBar/Timestamp
@onready var note_count_label: Label = $BottomBar/NoteCountLabel
@onready var sel_label: Label = $BottomBar/SelLabel
@onready var play_btn: Button = $TopBar/PlayBtn
@onready var speed_slider: HSlider = $TopBar/SpeedSlider
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var file_dialog_open: FileDialog = $FileDialogOpen
@onready var file_dialog_save: FileDialog = $FileDialogSave
@onready var audio_dialog: FileDialog = $AudioDialog

var cell_buttons: Array[Button] = []

var flash_time := 0.12
var last_flash_times := {}
var active_flashes := {}

func _ready():
	_build_grid()
	_connect_signals()
	timeline.draw.connect(_draw_timeline)
	timeline.gui_input.connect(_on_timeline_input)
	_refresh_timeline_size()

func _build_grid():
	grid_container.columns = GRID_COLS
	for r in range(GRID_ROWS):
		for c in range(GRID_COLS):
			var btn = Button.new()
			btn.custom_minimum_size = Vector2(64, 64)
			btn.text = "%d,%d" % [r, c]
			btn.pressed.connect(_on_cell_pressed.bind(r, c))
			grid_container.add_child(btn)
			cell_buttons.append(btn)

func _connect_signals():
	bpm_spin.value_changed.connect(func(v): bpm = v; _refresh_timeline_size())
	zoom_slider.value_changed.connect(func(v): zoom = v; _refresh_timeline_size())
	$TopBar/PlayBtn.pressed.connect(_on_play_pressed)
	$TopBar/StopBtn.pressed.connect(_on_stop_pressed)
	$TopBar/OpenBtn.pressed.connect(func(): file_dialog_open.popup_centered_ratio(0.6))
	$TopBar/SaveBtn.pressed.connect(_on_save_pressed)
	$TopBar/AudioBtn.pressed.connect(func(): audio_dialog.popup_centered_ratio(0.6))
	$TopBar/ClearBtn.pressed.connect(_on_clear_pressed)
	file_dialog_open.file_selected.connect(_on_map_opened)
	file_dialog_save.file_selected.connect(_on_map_saved)
	audio_dialog.file_selected.connect(_on_audio_loaded)
	audio_player.finished.connect(_on_audio_finished)

func _on_cell_pressed(row: int, col: int):
	if selected_cell == Vector2i(row, col):
		selected_cell = Vector2i(-1, -1)
		sel_label.text = "no cell selected"
	else:
		selected_cell = Vector2i(row, col)
		sel_label.text = "cell (%d, %d) selected" % [row, col]
	_update_cell_visuals()

func _update_cell_visuals():
	for r in range(GRID_ROWS):
		for c in range(GRID_COLS):
			var btn = cell_buttons[r * GRID_COLS + c]
			if selected_cell == Vector2i(r, c):
				btn.add_theme_color_override("font_color", Color("31a164"))
				btn.add_theme_stylebox_override("normal", _make_stylebox(Color("31a164"), 0.25))
			else:
				btn.remove_theme_color_override("font_color")
				btn.remove_theme_stylebox_override("normal")

func _make_stylebox(color: Color, alpha: float) -> StyleBoxFlat:
	var s = StyleBoxFlat.new()
	s.bg_color = Color(color.r, color.g, color.b, alpha)
	s.border_color = color
	s.set_border_width_all(2)
	s.set_corner_radius_all(6)
	return s

func time_to_x(t: float) -> float:
	return 20.0 + t * zoom

func x_to_time(x: float) -> float:
	return (x - 20.0) / zoom

func snap_to_grid(t: float) -> float:
	var beats_per_sec = bpm / 60.0
	var sub_interval = 1.0 / (beats_per_sec * 4.0)
	return round(t / sub_interval) * sub_interval

func _refresh_timeline_size():
	if not is_inside_tree():
		return
	var w = max(timeline_scroll.size.x, song_duration * zoom + 60.0)
	timeline.custom_minimum_size = Vector2(w, 200)
	timeline.size = Vector2(w, 200)
	timeline.queue_redraw()

func _draw_timeline():
	var w = timeline.size.x
	var h = timeline.size.y
	var row_h = h / GRID_ROWS
	var beats_per_sec = bpm / 60.0
	var beat_interval = 1.0 / beats_per_sec
	var sub_interval = beat_interval / 4.0

	var t = 0.0
	while t <= song_duration + sub_interval:
		var x = time_to_x(t)
		var is_beat = fmod(round(t / sub_interval), 4.0) == 0.0
		var color = Color(1, 1, 1, 0.12) if is_beat else Color(1, 1, 1, 0.04)
		var width = 1.0 if is_beat else 0.5
		timeline.draw_line(Vector2(x, 0), Vector2(x, h), color, width)
		if is_beat:
			timeline.draw_string(
				ThemeDB.fallback_font,
				Vector2(x + 2, 10),
				"%.2fs" % t,
				HORIZONTAL_ALIGNMENT_LEFT, -1, 9,
				Color(1, 1, 1, 0.35)
			)
		t += sub_interval

	for r in range(GRID_ROWS + 1):
		timeline.draw_line(
			Vector2(0, r * row_h),
			Vector2(w, r * row_h),
			Color(1, 1, 1, 0.1), 0.5
		)

	for note in notes:
		var x = time_to_x(note.time)
		var y = note.row * row_h + row_h * 0.5
		var col = Color("31a164")
		var radius = min(row_h * 0.38, 14.0)
		timeline.draw_circle(Vector2(x, y), radius, Color(col.r, col.g, col.b, 0.8))
		timeline.draw_arc(Vector2(x, y), radius, 0, TAU, 24, col, 1.5)
		timeline.draw_string(
			ThemeDB.fallback_font,
			Vector2(x - 3, y + 4),
			str(note.col),
			HORIZONTAL_ALIGNMENT_LEFT, -1, 9,
			Color(1, 1, 1, 0.9)
		)

func _on_timeline_input(event: InputEvent):
	if event is InputEventMouseButton:
		var pos = event.position
		var t = x_to_time(pos.x)
		var row_h = timeline.size.y / GRID_ROWS
		var row = int(pos.y / row_h)

		if event.button_index == MOUSE_BUTTON_MIDDLE and event.pressed:
			play_time = x_to_time(pos.x)
			time_stamp.value = play_time
			_update_playhead()
		
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if selected_cell.x == -1:
				play_time = x_to_time(pos.x)
				time_stamp.value = play_time
				_update_playhead()
				return
			if t < 0 or t > song_duration:
				return
			var snapped = snap_to_grid(t)
			var r = selected_cell.x
			var c = selected_cell.y
			var existing = -1
			for i in range(notes.size()):
				if notes[i].row == r and notes[i].col == c and abs(notes[i].time - snapped) < 0.02:
					existing = i
					break
			if existing >= 0:
				notes.remove_at(existing)
			else:
				notes.append({ "time": snapped, "row": r, "col": c })
				notes.sort_custom(func(a, b): return a.time < b.time)
			note_count_label.text = "notes: %d" % notes.size()
			timeline.queue_redraw()

		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			var closest = -1
			var closest_dist = 999.0
			for i in range(notes.size()):
				if notes[i].row == row:
					var d = abs(notes[i].time - t)
					if d < closest_dist and d < 20.0 / zoom:
						closest_dist = d
						closest = i
			if closest >= 0:
				notes.remove_at(closest)
				note_count_label.text = "notes: %d" % notes.size()
				timeline.queue_redraw()

func _on_play_pressed():
	if is_playing:
		return
	is_playing = true
	play_btn.text = "playing"
	if audio_player.stream:
		audio_player.seek(play_time)
		audio_player.pitch_scale = speed_slider.value
		audio_player.play(time_stamp.value)
	
func _on_stop_pressed():
	is_playing = false
	play_time = 0.0
	play_btn.text = "play"
	time_stamp.value = audio_player.get_playback_position()
	audio_player.stop()
	active_flashes = {}
	last_flash_times = {}
	# _update_playhead()

func _on_audio_finished():
	is_playing = false
	play_btn.text = "play"

func _process(delta):
	if not is_playing:
		return
	var speed = speed_slider.value
	if audio_player.stream and audio_player.playing:
		play_time = audio_player.get_playback_position()
	else:
		play_time += delta * speed
	if play_time >= song_duration:
		play_time = song_duration
		is_playing = false
		play_btn.text = "play"
	time_label.text = "%.3fs" % play_time
	_update_playhead()
	_check_note_hits()
	_update_flash_visuals(delta)

func _update_playhead():
	var x = time_to_x(play_time)
	playhead.position = Vector2(x - 1, 0)
	var scroll_w = timeline_scroll.size.x
	if is_playing and x > timeline_scroll.scroll_horizontal + scroll_w * 0.8:
		timeline_scroll.scroll_horizontal = int(x - scroll_w * 0.3)

func _check_note_hits():
	var hit_window := 0.05
	
	for i in range(notes.size()):
		var note = notes[i]
		
		if last_flash_times.has(i) and abs(play_time - last_flash_times[i]) < hit_window:
			continue
		
		if abs(play_time - note.time) < hit_window:
			last_flash_times[i] = play_time
			_flash_cell(note.row, note.col)

func _flash_cell(row: int, col: int):
	var key = Vector2i(row, col)
	active_flashes[key] = flash_time

func _update_flash_visuals(delta):
	for key in active_flashes.keys():
		active_flashes[key] -= delta
		
		var row = key.x
		var col = key.y
		var btn = cell_buttons[row * GRID_COLS + col]
		
		var t = active_flashes[key] / flash_time
		var alpha = clamp(t, 0, 1)
		
		btn.add_theme_stylebox_override(
			"normal",
			_make_stylebox(Color("31a164"), alpha * 0.6)
		)
		
		if active_flashes[key] <= 0:
			active_flashes.erase(key)
			_update_cell_visuals()

func _on_map_opened(path: String):
	map_path = path
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("ChartEditor: cannot open " + path)
		return
	var json = JSON.new()
	json.parse(file.get_as_text())
	notes = json.get_data()
	note_count_label.text = "notes: %d" % notes.size()
	timeline.queue_redraw()

func _on_save_pressed():
	if map_path == "":
		file_dialog_save.popup_centered_ratio(0.6)
	else:
		_write_map(map_path)

func _on_map_saved(path: String):
	map_path = path
	_write_map(path)

func _write_map(path: String):
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(notes, "\t"))
	print("ChartEditor: saved to ", path)

func _on_audio_loaded(path: String):
	var ext = path.get_extension().to_lower()
	var stream: AudioStream
	if ext == "ogg":
		stream = AudioStreamOggVorbis.load_from_file(path)
	elif ext == "mp3":
		stream = AudioStreamMP3.new()
		var f = FileAccess.open(path, FileAccess.READ)
		stream.data = f.get_buffer(f.get_length())
	elif ext == "wav":
		stream = load(path)
	if stream:
		audio_player.stream = stream
		song_duration = stream.get_length()
		$TopBar/BPMSpin.get_parent().get_node_or_null("DurLabel")
		_refresh_timeline_size()
		print("ChartEditor: loaded audio, duration=%.2fs" % song_duration)
	else:
		push_error("ChartEditor: unsupported audio format: " + ext)

func _on_clear_pressed():
	notes.clear()
	note_count_label.text = "notes: 0"
	timeline.queue_redraw()
