extends Node

var bpm = 120.0
var current_time = 0.0
var is_playing = false

@onready var audio_player = $AudioStreamPlayer

func start(song: AudioStream):
	audio_player.stream = song
	audio_player.play()
	is_playing = true

func stop():
	audio_player.stop()
	is_playing = false

func _process(delta):
	if is_playing:
		current_time = audio_player.get_playback_position() + AudioServer.get_time_since_last_mix() - AudioServer.get_output_latency()
		
func get_song_length() -> float:
	if audio_player.stream:
		return audio_player.stream.get_length()
	return 0.0
