extends Minigame

@onready var misses = $Misses

@export var song_path = "res://music/RudeBuster/RudeBuster"
func start():
	if mult == 1:
		instruction_text = "Hit the block with your mouse " + "and don't miss more than 15"
	if mult == 2:
		instruction_text = "Hit the block with your mouse " + "and don't miss more than 10"
	time_limit = Conductor.get_song_length()

func _process(delta: float) -> void:
	misses.text = "Misses " + "\n" + str(Conductor.notes_missed)
	if Conductor.notes_missed >= 15 and mult == 1:
		Conductor.stop()
		lose()
	if Conductor.notes_missed >= 10 and mult == 2:
		Conductor.stop()
		lose()

func lose():
	emit_signal("game_lost")

func stop():
	mult += 1
	emit_signal("game_won")
