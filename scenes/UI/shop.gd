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
		card.purchased.connect(_on_item_purchased.bind(item_data))
		card.mouse_entered.connect(_update_label.bind(item_data))

func _on_item_purchased(item_data: Dictionary) -> void:
	Inventory.add_item(item_data.id)
	label.text = "Congrats on your [b]%s[/b]" % item_data.name

func _update_label(item_data: Dictionary) -> void:
	label.text = "[b]%s[/b]\n%s" % [item_data.name, item_data.desc]

func _on_button_button_up() -> void:
	emit_signal("shop_finished")
