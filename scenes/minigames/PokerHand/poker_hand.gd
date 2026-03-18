extends Minigame

@onready var card_scene = preload("res://scenes/minigames/PokerHand/card.tscn")
@onready var container = $Container
@onready var value_sheet = preload("res://images/DeckOfCards.png")
@onready var back_sheet = preload("res://images/PC _ Computer - Balatro - Playing Cards - Card Backs, Enhancers and Seals.png")
var hand_size = 6
var rng = RandomNumberGenerator.new()
var hand = []
var hand_counter = 0
var held = 0
var held_hand = []


func start():
	time_limit = 7
	instruction_text = "Make the best hand with the following cards!"
	
	for i in range(hand_size):
		var new_card = card_scene.instantiate()
		container.add_child(new_card)

		new_card.value_sheet = value_sheet
		new_card.back_sheet = back_sheet

		# Random card
		new_card.suit = rng.randi_range(0,3)
		new_card.value = rng.randi_range(0,12)
		new_card.set_card(new_card.suit,new_card.value)
		new_card.index = (13 * new_card.suit) + new_card.value
		hand.append(new_card.index)
		new_card.tween = null
		new_card.pressed.connect(Callable(self, "on_button_pressed").bind(new_card))

func on_button_pressed(button: TextureButton):
	
	if button.tween:
		button.tween.kill()
	button.tween = create_tween()
		
		
	if held < 5 and !button.focused:
		button.focused = !button.focused
		button.tween.tween_property(button, "position", button.position + Vector2(0,-30), 0.1).set_ease(Tween.EASE_OUT)
		held_hand.append(button.index)
		held += 1
	elif button.focused:
		button.focused = false
		button.tween.tween_property(button, "position", button.position + Vector2(0,30), 0.1).set_ease(Tween.EASE_OUT)
		held_hand.erase(button.index)
		held -= 1 

func _on_confirm_pressed() -> void:
	best_hand()
	pass # Replace with function body.

func check_hand():
	
	pass
func best_hand():
	var test_hand = hand.duplicate()
	test_hand.sort()
	test_hand.reverse()
	
	
	pass
