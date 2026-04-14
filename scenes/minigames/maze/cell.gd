extends Node2D

var visited = false

var walls = {
	"top": true,
	"right": true,
	"bottom": true,
	"left": true
}

@onready var top_wall = $TopWall
@onready var right_wall = $RightWall
@onready var bottom_wall = $BottomWall
@onready var left_wall = $LeftWall

@onready var top_shape = $TopWall/CollisionShape2D
@onready var right_shape = $RightWall/CollisionShape2D
@onready var bottom_shape = $BottomWall/CollisionShape2D
@onready var left_shape = $LeftWall/CollisionShape2D

func update_walls():
	top_wall.visible = walls["top"]
	right_wall.visible = walls["right"]
	bottom_wall.visible = walls["bottom"]
	left_wall.visible = walls["left"]

	top_shape.disabled = not walls["top"]
	right_shape.disabled = not walls["right"]
	bottom_shape.disabled = not walls["bottom"]
	left_shape.disabled = not walls["left"]

func update_wall_size(new_size):
	top_shape.shape.size.x = new_size
	right_shape.shape.size.y = new_size
	bottom_shape.shape.size.x = new_size
	left_shape.shape.size.y = new_size
	
