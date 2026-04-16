extends Minigame


@onready var misses = $Misses
@onready var combo_text = $Combo
@onready var score_text = $Score
@onready var accuracy_text = $Accuracy
@onready var multiplier_text = $Multiplier

@export var song = "RudeBuster"
const song_path = "res://music/"

func start():
	if mult == 1:
		instruction_text = "Hit the block with your mouse " + "and don't miss more than 15"
	if mult == 2:
		instruction_text = "Hit the block with your mouse " + "and don't miss more than 10"
	time_limit = Conductor.get_song_length()

func get_song_path():
	return song_path + song + "/" + song

func _process(delta: float) -> void:
	misses.text = "Misses " + "\n" + str(Conductor.notes_missed)
	score_text.text = "Score" + "\n" + str(Conductor.score)
	combo_text.text = "Combo " + "\n" + str(Conductor.combo)
	accuracy_text.text = "Accuracy " + "\n" + str(snapped(Conductor.get_accuracy(), 0.1)) + "%"
	multiplier_text.text = str(Conductor.multiplier) + "x"
	if Conductor.notes_missed >= 15 and mult == 1:
		Conductor.stop()
		lose()
	if Conductor.notes_missed >= 10 and mult == 2:
		Conductor.stop()
		lose()

func lose():
	emit_signal("game_lost")

func stop():
	emit_signal("game_won")
