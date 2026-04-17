extends Node
class_name Minigame

@warning_ignore("unused_signal")
signal game_won
@warning_ignore("unused_signal")
signal game_lost

var instruction_text := "something broke lol"
var time_limit := 5
var mult = 1
@export var priority: bool = false
@export var disable_timer_addition: bool = false

func start():
	pass

func stop():
	emit_signal("game_lost")
