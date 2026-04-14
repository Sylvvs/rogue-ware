extends Minigame

@export var song_path = "res://music/RudeBuster/RudeBuster"
func start():
	instruction_text = "Hit the block with your mouse"
	mult = 1
	time_limit = Conductor.get_song_length()

func stop():
	emit_signal("game_won")
