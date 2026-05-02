extends TextureButton

@export var value_sheet: Texture2D
@export var back_sheet: Texture2D
@export var tile_size: Vector2i = Vector2i(71,95)

var suit: int = 0
var value: int = 0
var index = 0

var focused = false

var tween = null
@onready var value_sprite = $Value
@onready var background_sprite = $Background

func _ready():
	update_sprite()

func set_card(s, v):
	suit = s
	value = v
	update_sprite()
	
func update_sprite():
	if not value_sheet or not back_sheet:
		return

	var face := AtlasTexture.new()
	face.atlas = value_sheet
	face.region = Rect2(Vector2(value * tile_size.x, suit * tile_size.y), tile_size)
	value_sprite.texture = face

	var back := AtlasTexture.new()
	back.atlas = back_sheet
	back.region = Rect2(Vector2(71,0), tile_size)
	background_sprite.texture = back
