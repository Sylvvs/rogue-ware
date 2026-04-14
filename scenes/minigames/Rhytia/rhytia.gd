extends Minigame

@export var song_path = "res://music/RudeBuster/RudeBuster"
func start():
	instruction_text = "Hit the block with your mouse"
	mult = 1
	time_limit = Conductor.get_song_length()

func _process(delta: float) -> void:
	if Conductor.notes_missed >= 15:
		Conductor.stop()
		lose()

func lose():
	emit_signal("game_lost")

func stop():
	emit_signal("game_won")
