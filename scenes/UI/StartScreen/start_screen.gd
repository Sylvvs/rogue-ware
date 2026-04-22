extends Control

@onready var knapper = $VBoxContainer
@onready var play_knap = $VBoxContainer/Play
@onready var settings_knap = $VBoxContainer/Settings
@onready var quit_knap = $VBoxContainer/Quit
@onready var tutorials_knap = $VBoxContainer/Tutorials

func _ready() -> void:
	play_knap.text = "PLAY"
	settings_knap.text = "SETTINGS"
	quit_knap.text = "QUIT"
	tutorials_knap.text = "TUTORIALS"



func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/GameHandler.tscn")
	pass # Replace with function body.


func _on_settings_pressed() -> void:
	pass # Replace with function body.


func _on_quit_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.

func _on_tutorials_pressed() -> void:
	print('ding')
	get_tree().change_scene_to_file("res://scenes/UI/Tutorials/tutorial_screen.tscn")
	pass # Replace with function body
