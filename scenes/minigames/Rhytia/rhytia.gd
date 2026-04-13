extends Minigame


func start():
	instruction_text = "Hit the block with your mouse"
	time_limit = 300
	mult = 1

func stop():
	emit_signal("game_won")
