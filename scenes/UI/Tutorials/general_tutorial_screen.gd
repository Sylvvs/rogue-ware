extends Control

# Define your tutorial pages as an array of [image_path, text]
var pages = [
	["res://images/tutorial/tutorial_1.png", "Welcome! This is the general tutorial for the game. After this you will be ready to conquer the game!"],
	["res://images/tutorial/tutorial_2.png", "When you launch the game you get a random minigame. Each minigame needs you to do something specific! It will always be stated what you need to do here!"],
	["res://images/tutorial/tutorial_3.png", "There are a few other important visual indicators. Namely the bomb which shows how much time you have left, and then the coin pouch where you can see how many coins you have!"],
	["res://images/tutorial/tutorial_4.png", "Here is the shop! It appears every so often after a minigame and offers 9 random items! You can buy as many as you want as long as you can afford it! Every item does something unique, try to find the best combos!"],
	["res://images/tutorial/tutorial_5.png", "After you have bought items they will appear on the left side! You don't have to do anything with your passive items but for your active items you have to press on them to activate their effects!"],
	["res://images/tutorial/tutorial_6.png", "Whenever you don't beat a minigame you lose a life... Try not to lose all your health points!"]
]

var current_page = 0

@onready var texture_rect = $PanelContainer/Tutorialbox/TextureRect
@onready var label = $PanelContainer/Tutorialbox/Buttonbox/RichTextLabel
@onready var back_button = $PanelContainer/Tutorialbox/Buttonbox/TextureButton
@onready var next_button = $PanelContainer/Tutorialbox/Buttonbox/TextureButton2

func _ready():
	update_page()

func update_page():
	var page = pages[current_page]
	var image = Image.load_from_file(page[0])
	var texture = ImageTexture.create_from_image(image)
	texture_rect.texture = texture
	print(texture_rect.texture)
	label.text = page[1]
	
	# Hide back button on first page
	back_button.visible = current_page > 0
	
	# Change Next to "Finish" on last page
	if current_page == pages.size() - 1:
		next_button.text = "Finish"
	else:
		next_button.text = "Next"

func _on_next_button_pressed():
	print('ding')
	

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


func _on_next_button_2_pressed() -> void:
	if current_page < pages.size() - 1:
		current_page += 1
		update_page()
	else:
		get_tree().change_scene_to_file("res://scenes/UI/Tutorials/tutorial_screen.tscn")
