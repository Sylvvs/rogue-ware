extends Node

var owned: Array[Dictionary] = []
var all_items: Array = []

signal inventory_changed
signal coins_changed(amount: int)

var minigames_beaten = 0

const PASSIVE_DEFAULTS = {
	"time_bonus": 0.0,
	"coin_multiplier": 1.0,
	"health_cap": 3.0
}

signal passive_changed(stat: String)

func get_passive(stat: String) -> float:
	var default = PASSIVE_DEFAULTS.get(stat, 0.0)
	var is_multiplicative = stat.ends_with("_multiplier")
	var result = default
	for item in owned:
		if item.get("type") != "passive": continue
		if item.get("effect", {}).get("stat") != stat: continue
		if is_multiplicative:
			result *= item.effect.value
		else:
			result += item.effect.value
	return result

var coins = 0:
	set(value):
		coins = value
		if coins < 0: coins = 0
		emit_signal("coins_changed", coins)

func _ready() -> void:
	var text = FileAccess.open("res://scenes/UI/shop_items.json", FileAccess.READ).get_as_text()
	all_items = JSON.parse_string(text)

func get_item(id: int) -> Dictionary:
	return all_items.filter(func(i): return i.id == id).front()

func add_item(id) -> void:
	var item = get_item(id)
	owned.append(item)
	emit_signal("inventory_changed")
	if item.get("type") == "passive":
		passive_changed.emit(item.effect.get("stat", ""))

func get_time_bonus() -> float:
	return _sum_passive("time_bonus")

func get_coin_multiplier() -> float:
	var base = 1.0
	for item in _get_passives("coin_multiplier"):
		base *= item.effect.value
	return base

func _get_passives(stat: String) -> Array:
	return owned.filter(func(i): 
		return i.type == "passive" and i.get("effect", {}).get("stat") == stat
	)

func _sum_passive(stat: String) -> float:
	var total = 0.0
	for item in _get_passives(stat):
		total += item.effect.value
	return total

func has_active(action: String) -> bool:
	return owned.any(func(i): return i.type == "active" and i.effect.get("action") == action)

func consume_active(action: String) -> bool:
	for i in range(owned.size()):
		if owned[i].type == "active" and owned[i].effect.get("action") == action:
			owned.remove_at(i)
			return true
	return false
