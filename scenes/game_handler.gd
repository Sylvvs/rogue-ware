extends Node2D

@onready var MinigameContainer: Node2D = $MinigameContainer
@onready var UIContainer: CanvasLayer = $UIContainer
@onready var intermission = $IntermissionTime
@onready var HUD = preload("res://scenes/UI/hud.tscn")

@onready var MINIGAMES = [
	preload("res://scenes/minigames/CatchApples.tscn")
]

var current_minigame = null
var current_timer = null

func _ready() -> void:
	intermission.start()

func start_random_minigame():
	intermission.stop()
	
	var scene = MINIGAMES.pick_random()
	var game = scene.instantiate()
	
	MinigameContainer.add_child(game)
	current_minigame = game
	
	game.game_won.connect(_on_game_won)
	game.game_lost.connect(_on_game_lost)
	
	var timer = HUD.instantiate()
	UIContainer.add_child(timer)
	current_timer = timer
	
	game.start()
	timer.time = game.time_limit
	timer.time_out.connect(_on_timer_finished)
	
	timer.change_text(game.instruction_text)
	timer.start()

func clear_current_minigame():
	if current_minigame:
		current_minigame.queue_free()
		current_minigame = null

func _on_timer_finished():
	current_minigame.stop()

func stop_game():
	if current_timer:
		current_timer.queue_free()
	clear_current_minigame()
	intermission.start()

func _on_game_won():
	print("yay u did it")
	stop_game()

func _on_game_lost():
	print("holy washed")
	stop_game()
	
func _on_intermission_time_timeout() -> void:
	start_random_minigame()
