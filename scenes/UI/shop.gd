extends CanvasLayer

@onready var label: RichTextLabel = $Padding/VBox/Label
@onready var item_container: GridContainer = $Padding/VBox/Itembackground/Padding2/ItemContainer

signal shop_finished

const ItemCard = preload("res://scenes/UI/ItemHolder.tscn")
const SHOP_SIZE = 9  

func _ready() -> void:
	populate()

func populate() -> void:
	for child in item_container.get_children():
		child.queue_free()
	var pool = Inventory.all_items.duplicate()
	pool.shuffle()
	var offered = pool.slice(0, SHOP_SIZE)
	for item_data in offered:
		var card = ItemCard.instantiate()
		item_container.add_child(card)
		card.setup(item_data)
		card.set_meta("item_data", item_data)
		card.purchased.connect(_on_item_purchased.bind(item_data))
		card.mouse_entered.connect(_update_label.bind(item_data))
		#if Inventory.coins < item_data.get("cost", 0):
			#card.disabled = true

	Inventory.coins_changed.connect(_on_coins_changed)

func _on_coins_changed(_amount: int):
	var cards = item_container.get_children()
	for i in range(cards.size()):
		
		var item_data = cards[i].get_meta("item_data")
		cards[i].disabled = Inventory.coins < item_data.get("cost", 0)

func _on_item_purchased(item_data: Dictionary) -> void:
	if Inventory.coins < item_data.get("cost", 0):
		label.text = "Not enough coins!"
		return
	Inventory.coins -= item_data.get("cost", 0)
	Inventory.add_item(item_data.id)
	label.text = "Congrats on your [b]%s[/b]" % item_data.name


func _update_label(item_data: Dictionary) -> void:
	label.text = "[b]%s[/b]\n%s" % [item_data.name, item_data.desc]

func _on_button_button_up() -> void:
	if Inventory.coins_changed.is_connected(_on_coins_changed):
		Inventory.coins_changed.disconnect(_on_coins_changed)
	emit_signal("shop_finished")
