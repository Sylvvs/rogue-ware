extends Control

@onready var knapper = $VBoxContainer
@onready var play_knap = $VBoxContainer/Play
@onready var settings_knap = $VBoxContainer/Settings
@onready var quit_knap = $VBoxContainer/Quit
@onready var tutorials_knap = $VBoxContainer/Tutorials
@onready var high_detail = $HighDetail
@onready var background_high = $BackgroundHigh
@onready var background_low = $BackgroundLow

var background_on = false

func _ready() -> void:
	play_knap.text = "PLAY"
	settings_knap.text = "SETTINGS"
	quit_knap.text = "QUIT"
	tutorials_knap.text = "TUTORIALS"


func _process(delta: float) -> void:
	if background_on == true:
		background_low.visible = false
		background_high.visible = true
	else: 
		background_on = false
		background_low.visible = true
		background_high.visible = false

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/GameHandler.tscn")
	pass # Replace with function body.


func _on_settings_pressed() -> void:
	pass # Replace with function body.


func _on_quit_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.


func _on_tutorials_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/Tutorials/platformer_tutorial.tscn")
	pass # Replace with function body.


func _on_high_detail_toggled(toggled_on: bool) -> void:
	if toggled_on:
		background_on = true
	else:
		background_on = false
	pass # Replace with function body.
