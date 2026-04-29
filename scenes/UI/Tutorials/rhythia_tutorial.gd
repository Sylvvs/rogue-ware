extends Control

var current_step = 0
var steps_shown = []

var tutorial_steps = [
	{
		"trigger": "immediate",
		"title": "Welcome to Rhytia!",
		"body": "Your real mouse cursor is hidden.\nTry moving your mouse, see the white dot on the grid? That's your cursor in this game."
	},
	{
		"trigger": "immediate",
		"title": "A note is coming",
		"body": "See the square extending?\nMove your cursor over it before it becomes full and disappears."
	},
	{
		"trigger": "first_hit",
		"title": "Nice hit :D",
		"body": "That's all there is to it.\nKeep hovering over circles as they appear."
	},
	{
		"trigger": "first_miss",
		"title": "That was a miss.",
		"body": "If your cursor isn't on the circle when it finishes shrinking, it's a miss.\nToo many misses and you lose"
	},
	{
		"trigger": "combo_4",
		"title": "You got a Combo!, this makes the Multiplier go up",
		"body": "4 hits in a row raises your score multiplier.\n it goes from 1x -> 2x -> 4x -> 8x\nMissing resets it."
	}
]

@onready var rhytia_viewport_container = $RhytiaViewportContainer
@onready var rhytia_viewport = $RhytiaViewportContainer/SubViewport
@onready var overlay_panel = $OverlayPanel
@onready var overlay_title = $OverlayPanel/VBox/Title
@onready var overlay_body = $OverlayPanel/VBox/Body
@onready var dismiss_button = $OverlayPanel/VBox/DismissButton
@onready var back_button = $BackButton
@onready var step_label = $StepLabel

var rhytia_instance = null
var waiting_for_dismiss = false
var tracked_hits = 0
var tracked_misses = 0
var tracked_combo = 0
var poll_timer = 0.0
var game_ended = false
var elapsed_time = 0.0

const grid_cols = 3
const grid_rows = 3
const cell_size = 145
const grid_offset = Vector2(370, 75)

func _ready():
	dismiss_button.pressed.connect(_dismiss_overlay)
	back_button.pressed.connect(_go_back)
	back_button.process_mode = Node.PROCESS_MODE_ALWAYS

	var rhytia_scene = load("res://scenes/minigames/Rhytia/rhytia.tscn")
	rhytia_instance = rhytia_scene.instantiate()
	rhytia_instance.song = "Red&Blue"
	rhytia_instance.full_song = false
	rhytia_instance.mult = 1.0
	rhytia_instance.game_won.connect(_on_rhytia_won)
	rhytia_instance.game_lost.connect(_on_rhytia_lost)
	rhytia_viewport.add_child(rhytia_instance)
	rhytia_instance.get_node("NoteManager").tutorial_mode = true
	rhytia_instance.start()
	rhytia_instance.note_man_start()

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	_show_step_by_trigger("immediate")

func _process(delta):
	if rhytia_instance == null or game_ended:
		return
	if Conductor.is_playing:
		elapsed_time += delta
		if elapsed_time >= rhytia_instance.time_limit:
			rhytia_instance.stop()
			return
	poll_timer += delta
	if poll_timer < 0.1:
		return
	poll_timer = 0.0

	var hits = Conductor.successful_hits
	var misses = Conductor.notes_missed
	var combo = Conductor.combo

	if hits > tracked_hits:
		tracked_hits = hits
		if hits == 1:
			_show_step_by_trigger("first_hit")

	if misses > tracked_misses:
		tracked_misses = misses
		if misses == 1:
			_show_step_by_trigger("first_miss")

	if combo >= 4 and tracked_combo < 4:
		tracked_combo = combo
		_show_step_by_trigger("combo_4")

func _show_step_by_trigger(trigger: String):
	for i in range(tutorial_steps.size()):
		if i in steps_shown:
			continue
		var step = tutorial_steps[i]
		if step["trigger"] == trigger:
			steps_shown.append(i)
			_show_overlay(step["title"], step["body"])
			return

func _show_overlay(title: String, body: String):
	overlay_title.text = title
	overlay_body.text = body
	dismiss_button.text = "Got it ->"
	overlay_panel.visible = true
	overlay_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	waiting_for_dismiss = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	

func _dismiss_overlay():
	overlay_panel.visible = false
	waiting_for_dismiss = false
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_show_step_by_trigger("immediate")
	step_label.text = str(steps_shown.size()) + " / " + str(tutorial_steps.size()) + " tips seen"


func _on_rhytia_won():
	game_ended = true
	Conductor.stop()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = false 
	dismiss_button.text = "Back to Tutorials"
	if dismiss_button.pressed.is_connected(_dismiss_overlay):
		dismiss_button.pressed.disconnect(_dismiss_overlay)
	if not dismiss_button.pressed.is_connected(_go_back):
		dismiss_button.pressed.connect(_go_back)
	_show_overlay("Good job!", "You have completed the tutorial!\nYou're now ready for the real thing.")

func _on_rhytia_lost():
	game_ended = true
	Conductor.stop()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = false
	dismiss_button.text = "Back to Tutorials"
	if dismiss_button.pressed.is_connected(_dismiss_overlay):
		dismiss_button.pressed.disconnect(_dismiss_overlay)
	if not dismiss_button.pressed.is_connected(_go_back):
		dismiss_button.pressed.connect(_go_back)
	_show_overlay("Game Over!", "But don't worry, this was just practice.\nHead back and try again in the real game! :D")

func _go_back():
	get_tree().paused = false
	Conductor.stop()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file("res://scenes/UI/Tutorials/tutorial_screen.tscn")
