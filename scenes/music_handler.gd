extends CanvasLayer

var current_track: AudioStreamPlayer
var current_meta: Dictionary = {}
@onready var popup = $MusicPopUp
@onready var popup_text = $MusicPopUp/Panel/RichTextLabel
@onready var record = $MusicPopUp/Panel/TextureRect

@onready var ALL_TRACKS = [
	"res://music/Flocci/",
	"res://music/Red&Blue/",
	"res://music/Green&Purple/"
]

func play_track(base_path: String) -> void:
	
	var stream = load(base_path + ".mp3")


	var json_text = FileAccess.open(base_path + ".json", FileAccess.READ).get_as_text()
	current_meta = JSON.parse_string(json_text)

	if current_track:
		current_track.queue_free()

	current_track = AudioStreamPlayer.new()
	current_track.stream = stream
	add_child(current_track)
	current_track.bus = "Music"
	current_track.finished.connect(_on_track_finished)
	
	current_track.play()

	show_credits()

func _on_track_finished() -> void:
	play_random_track()

func get_credit_string() -> String:
	if current_meta.is_empty():
		return ""
	var title = "Now playing: %s (%s)" % [current_meta.title, int(current_meta.year)]
	var composer = "Composed by: %s" %current_meta.composer
	var album = "Song from: %s" %current_meta.album
	return title + "\n" + composer + "\n" + album

func _get_track_base(folder: String) -> String:
	var dir = DirAccess.open(folder)
	for file in dir.get_files():
		if file.ends_with(".mp3"):
			var stem = file.get_basename()
			return folder + stem
	return ""

func play_random_track() -> void:
	var folder = ALL_TRACKS.pick_random()
	var base = _get_track_base(folder)
	if base == "":
		push_error("No mp3 found in %s" % folder)
		return
	play_track(base)

var spin_tween: Tween
var popup_tween: Tween

func show_credits():
	if spin_tween:
		spin_tween.kill()
	if popup_tween:
		popup_tween.kill()

	record.pivot_offset = record.size / 2
	popup_text.text = get_credit_string()
	await get_tree().process_frame

	var start_pos = popup.position
	var end_pos = start_pos + Vector2(-(popup_text.size.x + record.size.x), 0)

	popup_tween = create_tween()
	popup_tween.tween_property(popup, "position", end_pos, 0.5)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

	popup_tween.tween_interval(2.0)

	popup_tween.tween_property(popup, "position", start_pos, 0.5)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN)

	spin_tween = create_tween().set_loops()
	spin_tween.tween_property(record, "rotation_degrees", 360, 1.0)\
		.as_relative()\
		.set_trans(Tween.TRANS_LINEAR)

func _on_panel_mouse_entered() -> void:
	var tween = create_tween()
	tween.tween_property(popup, "modulate:a", 0.2, 0.1)

func _on_panel_mouse_exited() -> void:
	var tween = create_tween()
	tween.tween_property(popup, "modulate:a", 1.0, 0.1)

func play_error_sound():
	current_track.pitch_scale = 1.0

	var bus_idx = AudioServer.get_bus_index("SFX Error")
	
	var distortion = AudioServer.get_bus_effect(bus_idx, 0)
	var lowpass = AudioServer.get_bus_effect(bus_idx, 1)
	
	lowpass.cutoff_hz = 20000
	
	var tween = create_tween()
	
	tween.tween_property(current_track, "pitch_scale", 0.7, 0.5)
	
	tween.parallel().tween_property(lowpass, "cutoff_hz", 800, 0.5)
	tween.tween_property(lowpass, "cutoff_hz", 20000, 0.7)

func recover_error_sound():
	var bus_idx = AudioServer.get_bus_index("SFX Error")
	
	var lowpass = AudioServer.get_bus_effect(bus_idx, 1)
	
	var tween = create_tween()
	
	tween.tween_property(current_track, "pitch_scale", 1.0, 0.4)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
	
	tween.parallel().tween_property(lowpass, "cutoff_hz", 20000, 0.4)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
