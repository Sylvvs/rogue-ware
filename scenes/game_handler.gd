extends Node2D

const BLOCK_SIZE = 5
const HARD_GAME_INDEX = 4

var health = 3
var loop = 0
var block_position = 0
var minigames_beaten = 0
var in_shop = false

@onready var MinigameContainer: Node2D = $MinigameContainer
@onready var UIContainer: CanvasLayer = $UIContainer
@onready var intermission = $IntermissionTime
@onready var music = $MusicHandler
@onready var HUD = preload("res://scenes/UI/hud.tscn")

@onready var MINIGAMES = [
	preload("res://scenes/minigames/CatchApples/CatchApples.tscn"),
	preload("res://scenes/minigames/Spamclick/SpamClick.tscn"),
	preload("res://scenes/minigames/SimonSays/SimonSays.tscn"),
	preload("res://scenes/minigames/TeachesTyping/Typing.tscn"),
	preload("res://scenes/minigames/PerfectCircle/PerfectCircle.tscn"),
	preload("res://scenes/minigames/Math/MathQuiz.tscn"),
	preload("res://scenes/minigames/PokerHand/PokerHand.tscn"),
	preload("res://scenes/minigames/GætEtTal/GætEtTal.tscn"),
	preload("res://scenes/minigames/TælObjekter/TælObejtker.tscn"),
	preload("res://scenes/minigames/Bullet hell/BulletHell.tscn"),
	preload("res://scenes/minigames/Platformer/Platformer.tscn"),
	preload("res://scenes/minigames/EuropeLocator/EuropeLocator.tscn"),
	preload("res://scenes/minigames/ApplesFromSky/apples_from_sky.tscn"),
	preload("res://scenes/minigames/ColorMatch/ColorMatch.tscn"),
	preload("res://scenes/minigames/NumberMemory/NumberMemory.tscn")
]

@onready var HARD_MINIGAMES = MINIGAMES

var current_minigame = null
var current_timer = null

var game_seed: int = 0

func _ready() -> void:
	apply_seed(randi())
	music.play_random_track()
	intermission.start()

func apply_seed(s: int) -> void:
	game_seed = s
	seed(game_seed)

func _hard_game_count() -> int:
	return 1 + loop

func _is_hard_slot() -> bool:
	var count = _hard_game_count()
	
	for i in range(1, count + 1):
		var slot = int(float(BLOCK_SIZE) / float(count + 1) * i)
		slot = clamp(slot, 1, BLOCK_SIZE - 1)
		if block_position == slot:
			return true
	return false

func _is_block_over() -> bool:
	return block_position >= BLOCK_SIZE

func _advance_and_decide() -> void:
	if _is_block_over():
		block_position = 0
		loop += 1
		_open_shop()
	elif _is_hard_slot():
		_start_hard_minigame()
	else:
		_start_normal_minigame()

func _start_normal_minigame() -> void:
	_launch(_get_pool(MINIGAMES).pick_random())

func _start_hard_minigame() -> void:
	_launch(_get_pool(HARD_MINIGAMES).pick_random())

# THIS IS USED FOR DEBUG
func _get_pool(scenes: Array) -> Array:
	var priority = scenes.filter(func(s):
		var tmp = s.instantiate()
		var has = "priority" in tmp and tmp.priority == true
		tmp.free()
		return has
	)
	if priority.is_empty():
		return scenes
	var names = ", ".join(priority.map(func(s): return s.resource_path.get_file().get_basename()))
	print("Forcing [%s] because they have priority!" % names)
	return priority

func _open_shop() -> void:
	in_shop = true
	print("REST TIME! (loop %d complete)" % loop)
	# TODO: the humble shop actually goes here
	intermission.start()

func _launch(scene: PackedScene) -> void:
	intermission.stop()
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

func stop_game():
	if current_timer:
		current_timer.queue_free()
	clear_current_minigame()
	block_position += 1
	intermission.start()

func _on_timer_finished():
	current_minigame.stop()
	
func _on_game_won():
	print("yay u did it")
	stop_game()
	minigames_beaten += 1

func _on_game_lost():
	health -= 1
	music.play_error_sound()
	print("holy washed")
	print('You beat: ' + JSON.stringify(minigames_beaten))
	minigames_beaten = 0
	stop_game()
	
func _on_intermission_time_timeout() -> void:
	if in_shop:
		in_shop = false
	music.recover_error_sound()
	_advance_and_decide()
