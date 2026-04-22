extends Control

@onready var retry_button = $VBoxContainer/Retry
@onready var back_to_main_screen = $VBoxContainer/MainScreen

func _ready() -> void:
	retry_button.text = "RETRY"
	back_to_main_screen.text = "BACK TO START SCREEN"
	


func _on_retry_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/GameHandler.tscn")



func _on_main_screen_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/StartScreen/start_screen.tscn")
	pass # Replace with function body.
