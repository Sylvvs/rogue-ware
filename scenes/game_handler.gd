extends Node2D

const BLOCK_SIZE = 5
const HARD_GAME_INDEX = 4

var health = 3
var max_health = health
var loop = 0
var block_position = 0
var minigames_beaten = 0
var in_shop = false
var song_path: String = ""
var mult = 1

@onready var MinigameContainer: Node2D = $MinigameContainer
@onready var UIContainer: CanvasLayer = $UIContainer
@onready var intermission = $IntermissionTime
@onready var music = $MusicHandler
@onready var HUD = preload("res://scenes/UI/GUI.tscn")
@onready var shop = preload("res://scenes/UI/Shop.tscn")
@onready var intermission_screen_file = preload("res://scenes/UI/Intermission.tscn")

var next_timer_mult = 1

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
	preload("res://scenes/minigames/Rhytia/rhytia.tscn"),
	preload("res://scenes/minigames/NumberMemory/NumberMemory.tscn"),
	preload("res://scenes/minigames/CrossyRoad/CrossyRoad.tscn")
]

@onready var HARD_MINIGAMES = MINIGAMES

var current_minigame = null
var current_timer = null
var current_HUD = null
var current_shop = null
var intermission_screen = null

var game_seed: int = 0
const BASE_SIZE = Vector2(1152, 648)

func _ready() -> void:
	apply_seed(randi())
	music.play_random_track()
	intermission_screen = intermission_screen_file.instantiate()
	intermission_screen.max_normal_hp = max_health
	intermission_screen.current_hp = health
	self.add_child(intermission_screen)
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
	current_shop = shop.instantiate()
	self.add_child(current_shop)
	current_shop.shop_finished.connect(_close_shop)

func _close_shop():
	current_shop.queue_free()
	in_shop = false
	intermission.start()

func _launch(scene: PackedScene) -> void:
	intermission.stop()
	var game = scene.instantiate()
	game.mult = mult
	current_minigame = game
	var scale_factor = 0.8
	if game is CanvasLayer or game is Control:
		var viewport = SubViewport.new()
		var container = SubViewportContainer.new()
		
		viewport.size = Vector2i(BASE_SIZE)
		viewport.transparent_bg = true
		
		container.stretch = true
		container.size = BASE_SIZE
		container.scale = Vector2(scale_factor, scale_factor)
		container.position = Vector2(BASE_SIZE.x * (1.0 - scale_factor), 0)
		
		container.mouse_filter = Control.MOUSE_FILTER_PASS
		viewport.handle_input_locally = true
		viewport.gui_embed_subwindows = true
		
		container.add_child(viewport)
		viewport.add_child(game)
		UIContainer.add_child(container)
		current_minigame = game
		
		current_minigame.set_meta("viewport_wrapper", container)
		
	else:
		MinigameContainer.add_child(game)
		MinigameContainer.scale = Vector2(scale_factor, scale_factor)
		MinigameContainer.position = Vector2(BASE_SIZE.x * (1-scale_factor), 0)
	
	if "song_path" in game:
		if not game.full_song:
			game.song = music.get_track_name()
		else:
			music.play_specific_track(game.song)
		music.play_track_with_conductor(game.get_song_path(), Conductor)
		game.note_man_start()
	game.game_won.connect(_on_game_won)
	game.game_lost.connect(_on_game_lost)

	var HUD_game = HUD.instantiate()
	UIContainer.add_child(HUD_game)
	current_HUD = HUD_game
	var timer = current_HUD.get_node("HUD") # ik the naming convention sucks but i cant be asked to change it
	current_timer = timer

	game.start()
	var additional_time = int(Inventory.get_passive("time_bonus"))
	if game.disable_timer_addition:
		additional_time = 0
	timer.time = int((game.time_limit * next_timer_mult) + additional_time)
	timer.init_time = game.time_limit
	timer.time_out.connect(_on_timer_finished)
	timer.skipping.connect(_on_game_won)
	timer.change_text(game.instruction_text)
	timer.start()
	next_timer_mult = 1

func freeze_timer(time_value):
	if current_minigame and current_timer:
		current_timer.freeze_time(time_value)

func clear_current_minigame():
	if current_minigame:
		if current_minigame.has_meta("viewport_wrapper"):
			current_minigame.get_meta("viewport_wrapper").queue_free()
		else:
			current_minigame.queue_free()
		current_minigame = null

func stop_game():
	if current_timer:
		current_timer.queue_free()
	clear_current_minigame()
	block_position += 1
	intermission.start()
	intermission_screen.visible = true

func _on_timer_finished():
	current_minigame.stop()
	
func _on_game_won():
	var coin_reward = 50 * Inventory.get_passive("coin_multiplier")
	intermission_screen.play_win(Inventory.coins, coin_reward)
	Inventory.coins += coin_reward
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	stop_game()
	minigames_beaten += 1
	mult += 0.05

func _on_game_lost():
	health -= 1
	music.play_error_sound()
	intermission_screen.lose_heart()
	stop_game()
	
func _on_intermission_time_timeout() -> void:
	if in_shop:
		return
	music.recover_error_sound()
	intermission_screen.visible = false
	_advance_and_decide()

func die():
	Inventory.minigames_beaten = minigames_beaten
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file("res://scenes/UI/LoseScreen/lose_screen.tscn")
