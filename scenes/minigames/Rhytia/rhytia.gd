extends Minigame


@onready var misses = $Control/Misses
@onready var combo_text = $Control/Combo
@onready var score_text = $Control/Score
@onready var accuracy_text = $Control/Accuracy
@onready var multiplier_text = $Control/Multiplier
@onready var multiplier_circle = $Control/MultiplierCircle

@export var song = "RudeBuster"
@export var full_song = false
const song_path = "res://music/"
var max_mult = 8.0
var last_multiplier = -1
func start():
	if mult == 1:
		instruction_text = "Hit the block with your mouse " + "and don't miss more than 15"
	if mult == 2:
		instruction_text = "Hit the block with your mouse " + "and don't miss more than 10"
	#time_limit = Conductor.get_song_length()
	time_limit = 20
	if full_song:
		time_limit = 300

func note_man_start():
	get_node("NoteManager").start()

func get_song_path():
	return song_path + song + "/" + song

func _process(delta: float) -> void:
	misses.text = "Misses " + "\n" + str(Conductor.notes_missed)
	score_text.text = "Score" + "\n" + str(Conductor.score)
	combo_text.text = "Combo " + "\n" + str(Conductor.combo)
	accuracy_text.text = "Accuracy " + "\n" + str(snapped(Conductor.get_accuracy(), 0.1)) + "%"
	multiplier_text.text = str(Conductor.multiplier) + "x"
	if Conductor.notes_missed >= 15 and mult == 1:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		Conductor.stop()
		lose()
	if Conductor.notes_missed >= 10 and mult == 2:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		Conductor.stop()
		lose()
		
	if Conductor.multiplier != last_multiplier:
		last_multiplier = Conductor.multiplier
		var target = (Conductor.multiplier / max_mult) * 100.0
		var tween = create_tween()
		tween.tween_property(multiplier_circle, "value", target, 0.2)


func lose():
	Conductor.stop()
	emit_signal("game_lost")

func stop():
	Conductor.stop()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	emit_signal("game_won")
