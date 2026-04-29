extends Control

@onready var coinLabel = $SideBar/MarginContainer/CoinLabel
@onready var passiveItems =$SideBar/MarginContainer2/VBoxContainer/PassiveItemContainer
@onready var activeItems =$SideBar/MarginContainer2/VBoxContainer/ActiveItemContainer

var itemHolder = preload("res://scenes/UI/ItemHolder.tscn")


func _ready():
	Inventory.inventory_changed.connect(refresh)
	Inventory.coins_changed.connect(_on_coins_changed)
	refresh()
	_on_coins_changed(Inventory.coins)

func _on_coins_changed(amount: int):
	coinLabel.text = str(amount) + " Coins"

func get_game_handler():
	return get_parent().get_parent()

func refresh():
	for child in passiveItems.get_children():
		child.queue_free()
	for child in activeItems.get_children():
		child.queue_free()

	for item in get_stacked_items():
		if not item.has("type"):
			continue
		var holder = itemHolder.instantiate()
		if item.type == "active":
			activeItems.add_child(holder)
			holder.used.connect(_on_active_used)
		else:
			passiveItems.add_child(holder)
			holder.disabled = true
		holder.setup(item)
		holder.get_node("VBox/Cost").hide()
		holder.custom_minimum_size = Vector2(30, 30)
		holder.size_flags_horizontal = Control.SIZE_FILL | Control.SIZE_EXPAND
		holder.size_flags_vertical = Control.SIZE_FILL | Control.SIZE_EXPAND

func get_stacked_items() -> Array:
	var stacks = {}
	for item in Inventory.owned:
		var id = item.id
		if stacks.has(id):
			stacks[id].count += 1
		else:
			stacks[id] = item.duplicate()
			stacks[id].count = 1
	return stacks.values()

func _on_active_used(data):
	var item = Inventory.get_item(data.id)
	Inventory.consume_active(item.effect.get("action"))
	_execute_action(item.effect)
	refresh()

func _execute_action(effect: Dictionary):
	var gh = get_game_handler()
	match effect.get("action"):
		"skip_minigame":
			gh._on_game_won()
		"mult_decrease":
			gh.mult -= 0.1
		"big_mult_decrease":
			gh.mult -= 0.25
			gh.health -= 1
			if gh.health <= 0:
				gh.die()
		"freeze_timer":
			gh.freeze_timer(effect.get("value"))
		"random_effect":
			var actions = ["skip_minigame", "double_points", "regain_life", "throwing_stone"]
			_execute_action({"action": actions.pick_random()})
		"regain_life":
			if gh.health <= gh.max_health:
				gh.health += 1
		"raw_meat":
			if gh.health <= gh.max_health:
				gh.health += 1
			gh.next_timer_mult *= 1.2
		"throwing_stone":
			if randi() % 2 == 0:
				gh.current_timer.time += 10
			else:
				gh.current_timer.time -= 10
		"deck_of_cards":
			var amount = randi_range(effect.get("min", -300), effect.get("max", 600))
			Inventory.coins += amount
		"bomb_minigame":
			gh.block_position -= 1
			gh.stop_game()
		"permanent_lives":
			gh.max_health += effect.get("value")
			gh.intermission_screen.gain_max_hp(effect.get("value"))
