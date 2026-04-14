extends Button
signal purchased

@onready var image: TextureRect = $VBox/Image
@onready var name_label: RichTextLabel = $VBox/Name
@onready var cost_label: RichTextLabel = $VBox/Cost

func setup(data: Dictionary) -> void:
	name_label.text = data.name
	cost_label.text = JSON.stringify(data.cost)
	image.texture = load(data.image)
	self.pressed.connect(func(): purchased.emit())
