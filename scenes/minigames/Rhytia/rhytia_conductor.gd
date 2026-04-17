extends Node

var bpm = 120.0
var current_time = 0.0
var is_playing = false
var notes_missed = 0
var score = 0
var combo = 0
var multiplier = 1
var total_notes = 0
var successful_hits = 0
var mult_levels = [1, 2, 4, 8]
var fake_mouse: Sprite2D = null
@onready var audio_player = $AudioStreamPlayer

func start(song: AudioStream, time: float):
	audio_player.volume_db = -80
	notes_missed = 0
	current_time = time
	score = 0
	combo = 0
	multiplier = 1
	total_notes = 0
	successful_hits = 0
	
	audio_player.stream = song
	audio_player.play(time)
	is_playing = true

func stop():
	audio_player.stop()
	is_playing = false
	notes_missed = 0
	current_time = 0.0

func _process(_delta):
	if is_playing:
		current_time = audio_player.get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency()

func get_accuracy() -> float:
	if total_notes == 0:
		return 100.0
	if notes_missed == 0:
		return 100.0
	return (float(successful_hits) / float(total_notes)) * 100.0
	

func get_song_length() -> float:
	if audio_player.stream:
		return audio_player.stream.get_length() # lol
	return 0.0
