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
	if best_hand() == best_hand(held_hand):
		emit_signal("game_won")



func best_hand(held_cards = null):
	var cards = hand.duplicate()
	if held_hand == held_cards:
		cards = held_cards
		if cards == []:
			return
	
	var suits = []
	var values = []
	for idx in cards:
		suits.append(idx / 13)
		values.append(idx % 13)
	
	# Count occurrences of each value
	var value_counts = {}
	for v in values:
		value_counts[v] = value_counts.get(v, 0) + 1
	
	var counts = value_counts.values()
	counts.sort()
	counts.reverse()  # e.g. [3, 2, 1] for three-of-a-kind + pair + kicker
	
	# Check flush: all same suit (only possible with 5 cards from your held hand)
	var is_flush = false
	if cards.size() >= 5:
		var held_suits = cards.map(func(i): return i / 13)
		is_flush = held_suits.count(held_suits[0]) == 5
	
	# Check straight: 5 consecutive values (needs sorted unique values)
	var is_straight = false
	if cards.size() >= 5:
		var held_vals = cards.map(func(i): return i % 13)
		held_vals.sort()
		# Check normal straight
		var consecutive = true
		for i in range(1, held_vals.size()):
			if held_vals[i] != held_vals[i-1] + 1:
				consecutive = false
				break
		# Check ace-low straight (A-2-3-4-5): ace is 12, so [0,1,2,3,12]
		var ace_low = held_vals == [0, 1, 2, 3, 4]
		is_straight = consecutive or ace_low
	
	# Evaluate hand rank
	if is_straight and is_flush:
		var held_vals = held_hand.map(func(i): return i % 13)
		if held_vals.has(0) and held_vals.has(11):  # A + K = royal
			return "Royal Flush"
		return "Straight Flush"
	
	if counts[0] == 4:
		return "Four of a Kind"
	
	if counts[0] == 3 and counts.size() > 1 and counts[1] == 2:
		return "Full House"
		
	if is_flush:
		return "Flush"
		
	if is_straight:
		return "Straight"
		
	if counts[0] == 3:
		return "Three of a Kind"
		
	if counts[0] == 2 and counts.size() > 1 and counts[1] == 2:
		return "Two Pair"
		
	if counts[0] == 2:
		return "One Pair"
	
	return "High Card"
