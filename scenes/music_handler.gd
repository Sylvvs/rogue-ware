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

# Call this with e.g. "res://music/cool_track/cool_track"  (no extension)
func play_track(base_path: String) -> void:
	# Load audio
	var stream = load(base_path + ".mp3")

	# Load metadata
	var json_text = FileAccess.open(base_path + ".json", FileAccess.READ).get_as_text()
	current_meta = JSON.parse_string(json_text)

	if current_track:
		current_track.queue_free()

	current_track = AudioStreamPlayer.new()
	current_track.stream = stream
	add_child(current_track)
	current_track.volume_db = -25
	current_track.play()

	show_credits()

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


func show_credits():
	record.pivot_offset = record.size / 2
	popup_text.text = get_credit_string()
	await get_tree().process_frame
	var tween = create_tween()
	
	var start_pos = popup.position
	
	var end_pos = start_pos + Vector2(-(popup_text.size.x + record.size.x), 0)
	print(popup_text.size.x)
	
	var spin_tween = create_tween().set_loops()

	spin_tween.tween_property(record, "rotation_degrees", record.rotation_degrees + 360, 1.0)\
		.as_relative()\
		.set_trans(Tween.TRANS_LINEAR)

	tween.tween_property(popup, "position", end_pos, 0.5)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
	
	tween.tween_interval(2.0)
	
	tween.tween_property(popup, "position", start_pos, 0.5)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN)

func _on_panel_mouse_entered() -> void:
	var tween = create_tween()
	tween.tween_property(popup, "modulate:a", 0.2, 0.1)

func _on_panel_mouse_exited() -> void:
	var tween = create_tween()
	tween.tween_property(popup, "modulate:a", 1.0, 0.1)
