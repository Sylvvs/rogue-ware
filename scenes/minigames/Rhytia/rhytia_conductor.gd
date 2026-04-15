extends Node

var bpm = 120.0
var current_time = 0.0
var is_playing = false
var notes_missed = 0
@onready var audio_player = $AudioStreamPlayer

func start(song: AudioStream):
	notes_missed = 0
	current_time = 0.0
	audio_player.stream = song
	audio_player.play()
	is_playing = true

func stop():
	audio_player.stop()
	is_playing = false
	notes_missed = 0
	current_time = 0.0

func _process(_delta):
	if is_playing:
		current_time = audio_player.get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency()
		
func get_song_length() -> float:
	if audio_player.stream:
		return audio_player.stream.get_length() - 70 # lol
	return 0.0
