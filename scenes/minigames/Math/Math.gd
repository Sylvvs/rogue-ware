extends Minigame

const BASE_PATH = "res://scenes/minigames/Math/MatematikTing/"
const QUESTIONS = [
	{ "text": "Solve for x:", "question": BASE_PATH + "1/S.png", "correct": BASE_PATH + "1/R.png", "wrong": [BASE_PATH + "1/F1.png", BASE_PATH + "1/F2.png", BASE_PATH + "1/F3.png"] },
	{ "text": "Which is a solution to ", "question": BASE_PATH + "2/S.png", "correct": BASE_PATH + "2/R.png", "wrong": [BASE_PATH + "2/F1.png", BASE_PATH + "2/F2.png", BASE_PATH + "2/F3.png"] },
	{ "text": "What is ?", "question": BASE_PATH + "3/S.png", "correct": BASE_PATH + "3/R.png", "wrong": [BASE_PATH + "3/F1.png", BASE_PATH + "3/F2.png", BASE_PATH + "3/F3.png"] },
	{ "text": "Simplify: ", "question": BASE_PATH + "4/S.png", "correct": BASE_PATH + "4/R.png", "wrong": [BASE_PATH + "4/F1.png", BASE_PATH + "4/F2.png", BASE_PATH + "4/F3.png"] },
	{ "text": "What is the derivative of ", "question": BASE_PATH + "5/S.png", "correct": BASE_PATH + "5/R.png", "wrong": [BASE_PATH + "5/F1.png", BASE_PATH + "5/F2.png", BASE_PATH + "5/F3.png"] },
	{ "text": "A fair dice is rolled twice. \nWhat is the chance that you roll 6 twice?", "question": BASE_PATH + "6/S.png", "correct": BASE_PATH + "6/R.png", "wrong": [BASE_PATH + "6/F1.png", BASE_PATH + "6/F2.png", BASE_PATH + "6/F3.png"] },
	{ "text": "Evaluate: ", "question": BASE_PATH + "7/S.png", "correct": BASE_PATH + "7/R.png", "wrong": [BASE_PATH + "7/F1.png", BASE_PATH + "7/F2.png", BASE_PATH + "7/F3.png"] },
	{ "text": "What is the value of x?", "question": BASE_PATH + "8/S.png", "correct": BASE_PATH + "8/R.png", "wrong": [BASE_PATH + "8/F1.png", BASE_PATH + "8/F2.png", BASE_PATH + "8/F3.png"] },
	{ "text": "What is the value of x?", "question": BASE_PATH + "9/S.png", "correct": BASE_PATH + "9/R.png", "wrong": [BASE_PATH + "9/F1.png", BASE_PATH + "9/F2.png", BASE_PATH + "9/F3.png"] },
	{ "text": "What is the value of x?", "question": BASE_PATH + "10/S.png", "correct": BASE_PATH + "10/R.png", "wrong": [BASE_PATH + "10/F1.png", BASE_PATH + "10/F2.png", BASE_PATH + "10/F3.png"] }
]

var selected_questions = []
var current_index = 0
var current_correct_index = -1

@onready var question_image: TextureRect = $QuestionImage
@onready var question_label: Label = $QuestionLabel
@onready var answer_buttons: Array = [
	$Button0,
	$Button1,
	$Button2,
	$Button3
]

func _ready():
	start()

func start():
	instruction_text = "Answer the math questions!"
	time_limit = 20
	time_limit = clamp(ceil(time_limit - (2 * mult)),5,20)
	var pool = QUESTIONS.duplicate()
	pool.shuffle()
	selected_questions = pool.slice(0, 3)
	current_index = 0
	_load_question()

func _load_question():
	if current_index >= selected_questions.size():
		emit_signal("game_won")
		return

	for btn in answer_buttons:
		if btn.pressed.is_connected(_on_answer_pressed):
			btn.pressed.disconnect(_on_answer_pressed)

	var q = selected_questions[current_index]
	question_label.text = q["text"]

	await get_tree().process_frame
	question_image.position.x = question_label.position.x + question_label.get_minimum_size().x + 5

	question_image.texture = load(q["question"])

	var answers = q["wrong"].duplicate()
	current_correct_index = randi() % 4
	answers.insert(current_correct_index, q["correct"])

	for i in range(4):
		answer_buttons[i].texture_normal = load(answers[i])
		answer_buttons[i].ignore_texture_size = true
		answer_buttons[i].stretch_mode = TextureButton.STRETCH_SCALE
		answer_buttons[i].pressed.connect(_on_answer_pressed.bind(i))

func _on_answer_pressed(index: int):
	if index == current_correct_index:
		current_index += 1
		_load_question()
	else:
		emit_signal("game_lost")
