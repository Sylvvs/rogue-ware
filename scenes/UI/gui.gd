extends Control

@onready var coinLabel = $SideBar/MarginContainer/CoinLabel
@onready var passiveItems =$SideBar/MarginContainer2/VBoxContainer/PassiveItemContainer
@onready var activeItems =$SideBar/MarginContainer2/VBoxContainer/ActiveItemContainer

var itemHolder = preload("res://scenes/UI/ItemHolder.tscn")
signal using_item(string: String)
var gameHandler = get_parent().get_parent()

func _ready():
	Inventory.inventory_changed.connect(refresh)
	refresh()

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
			holder.purchased.connect(_on_active_used)
		else:
			passiveItems.add_child(holder)
			holder.disabled = true
		holder.setup(item)
		holder.get_node("VBox/Cost").hide()
		holder.custom_minimum_size = Vector2(30, 30)
		holder.disabled = true
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

func _on_active_used(id: int):
	var item = Inventory.get_item(id)
	Inventory.consume_active(item.effect.get("action"))
	_execute_action(item.effect)
	refresh()

func _execute_action(effect: Dictionary):
	match effect.get("action"):
		"skip_minigame":
			
			pass
		"double_points":
			pass
		"triple_points":
			pass
		"freeze_timer":
			pass
		"random_effect":
			pass
		"regain_life":
			pass
		"raw_meat":
			pass
		"double_gold":
			pass
		"throwing_stone":
			pass
		"deck_of_cards":
			pass
		"bomb_minigame":
			pass
		"permanent_lives":
			pass
