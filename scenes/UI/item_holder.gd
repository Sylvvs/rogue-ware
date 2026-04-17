extends Button
signal purchased
signal used(data: Dictionary)

@onready var image: TextureRect = $VBox/Image
@onready var name_label: RichTextLabel = $VBox/Name
@onready var cost_label: RichTextLabel = $VBox/Cost

func setup(data: Dictionary) -> void:
	name_label.text = data.name if data.get("count", 1) <= 1 else data.name + " x" + str(data.count)
	cost_label.text = JSON.stringify(data.cost)
	image.texture = load(data.image)
	if not pressed.is_connected(_on_pressed):
		pressed.connect(_on_pressed.bind(data))

func _on_pressed(data: Dictionary):
	purchased.emit()
	used.emit(data)
