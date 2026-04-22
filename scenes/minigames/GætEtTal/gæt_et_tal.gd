extends Minigame

@onready var feedback_label: Label = $FeedbackLabel
@onready var previous_feedback: RichTextLabel = $RichTextLabel
@onready var number_input: LineEdit = $NumberInput
@onready var guess_button: TextureButton = $GuessButton
@onready var feedback_container: VBoxContainer = $VBoxContainer

var secret_number: int;

func _ready():
	start()


func start():
	instruction_text = 'Guess the number 1 between and 100!'
	time_limit = 22
	time_limit = clamp(ceil(time_limit - (2 * mult)),4,20)
	secret_number = randi_range(1, 100)
	guess_button.pressed.connect(OnGuessPressed)
	number_input.grab_focus()

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			get_viewport().set_input_as_handled()
			OnGuessSumbitted(number_input.text)

func OnGuessPressed():
	OnGuessSumbitted(number_input.text)

func OnGuessSumbitted(text: String):
	if not text.is_valid_int():
		feedback_label.text = 'Insert a number!'
		number_input.text = ""
		number_input.call_deferred("grab_focus")
		return
	
	var guess := text.to_int()
	
	if guess < 1 or guess > 100:
		feedback_label.text = "The number must be between 1 and 100!"
		number_input.text = ""
		number_input.call_deferred("grab_focus")
		return
	
	if guess < secret_number:
		feedback_label.text = "The number is higher!📈!"
		add_previous_feedback(guess)
	elif guess > secret_number:
		feedback_label.text = "The number is lower!📉"
		add_previous_feedback(guess)
	else:
		feedback_label.text = "Correct!🎉!"
		emit_signal("game_won")
		
	number_input.text = ""
	number_input.call_deferred("grab_focus")

func add_previous_feedback(guess):
	var new_feedback = previous_feedback.duplicate()
	var arrow = " [color=green]↑[/color]"
	if guess > secret_number:
		arrow = " [color=red]↓[/color]"
	new_feedback.text = JSON.stringify(guess) + arrow
	feedback_container.add_child(new_feedback)
	feedback_container.move_child(new_feedback, 0)

func stop():
	emit_signal("game_lost")
