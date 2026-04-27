extends Minigame


@onready var misses = $Control/Misses
@onready var combo_text = $Control/Combo
@onready var score_text = $Control/Score
@onready var accuracy_text = $Control/Accuracy
@onready var multiplier_text = $Control/Multiplier
@onready var multiplier_circle = $Control/MultiplierCircle

@export var song = ""
@export var full_song = false
const song_path = "res://music/"
var max_mult = 8.0
var last_multiplier = -1
var allowed_misses = 25
var allowed_misses_scale = 5
func start():
	allowed_misses = allowed_misses - round(allowed_misses_scale * mult)
	instruction_text = "Hit the block with your mouse " + "and don't miss more than:" + " " + str(allowed_misses)
	time_limit = 20
	time_limit = clamp(ceil(time_limit * mult),20,300)
	if full_song:
		time_limit = 300
		if get_parent().get_parent().name == "GameHandler":
			get_parent().get_parent().music.play_specific_track(song)
		else:
			note_man_start()
	

func note_man_start():
	get_node("NoteManager").start()
	if not get_parent().get_parent().name == "GameHandler":
		var stream = load(get_song_path() + ".mp3")
		Conductor.start(stream, 0, -20)
		time_limit = stream.length

func get_song_path():
	return song_path + song + "/" + song

func _process(delta: float) -> void:
	print(time_limit, allowed_misses)
	misses.text = "Misses " + "\n" + str(Conductor.notes_missed)
	score_text.text = "Score" + "\n" + str(Conductor.score)
	combo_text.text = "Combo " + "\n" + str(Conductor.combo)
	accuracy_text.text = "Accuracy " + "\n" + str(snapped(Conductor.get_accuracy(), 0.1)) + "%"
	multiplier_text.text = str(Conductor.multiplier) + "x"
	if Conductor.notes_missed >= allowed_misses:
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
