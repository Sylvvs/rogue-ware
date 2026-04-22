extends Control

# Define your tutorial pages as an array of [image_path, text]
var pages = [
	["res://images/apple.png", "Welcome! This is step one.\nLearn the basics here."],
	["res://images/ButtonDown.png", "Step two: Here's how to move\naround the world."],
	["res://images/circle.png", "Step three: You're ready!\nGood luck on your adventure."],
]

var current_page = 0

@onready var texture_rect = $Tutorialbox/TextureRect
@onready var label = $Tutorialbox/Buttonbox/RichTextLabel
@onready var back_button = $Tutorialbox/Buttonbox/TextureButton
@onready var next_button = $Tutorialbox/Buttonbox/TextureButton2

func _ready():
	update_page()

func update_page():
	var page = pages[current_page]
	texture_rect.texture = load(page[0])
	label.text = page[1]
	
	# Hide back button on first page
	back_button.visible = current_page > 0
	
	# Change Next to "Finish" on last page
	if current_page == pages.size() - 1:
		next_button.text = "Finish"
	else:
		next_button.text = "Next"

func _on_next_button_pressed():
	if current_page < pages.size() - 1:
		current_page += 1
		update_page()
	else:
		# Last page — close tutorial or go to main game
		get_tree().change_scene_to_file("res://scenes/main_game.tscn")

func _on_back_button_pressed():
	if current_page > 0:
		current_page -= 1
		update_page()

func _on_general_pressed() -> void:
	pass # Replace with function body.


func _on_platformer_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/Tutorials/platformer_tutorial.tscn")
	pass # Replace with function body.


func _on_bullethell_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/Tutorials/bullethell_tutorial.tscn")
	pass # Replace with function body.


func _on_rhythia_pressed() -> void:
	pass # Replace with function body.


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/StartScreen/start_screen.tscn")
	pass # Replace with function body.
