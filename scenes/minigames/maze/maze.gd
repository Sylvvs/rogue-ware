extends Minigame

var width = 10
var height = 10
var grid = []
var cell_size = 40

@onready var Cell = preload("res://scenes/minigames/maze/Cell.tscn")

func _ready():
	generate_grid()
	generate_maze()


func generate_grid():
	for y in range(height):
		grid.append([])
		for x in range(width):
			var cell = Cell.instantiate()
			add_child(cell)
			var base_size = 20.0
			var scale_factor = cell_size / base_size
			var center_offset = get_viewport().get_visible_rect().size/2 - Vector2(cell_size*(width/2),250)

			cell.scale = Vector2(scale_factor, scale_factor)
			cell.position = center_offset + Vector2(x * cell_size, y * cell_size)
			
			grid[y].append(cell)

func generate_maze():
	var stack = []
	var current = Vector2i(0, 0)
	grid[0][0].visited = true

	while true:
		var neighbors = get_unvisited_neighbors(current)

		if neighbors.size() > 0:
			var next = neighbors.pick_random()
			remove_walls(current, next)

			stack.append(current)
			current = next
			grid[current.y][current.x].visited = true

		elif stack.size() > 0:
			current = stack.pop_back()
		else:
			break
	update_all_cells()

func update_all_cells():
	for y in range(height):
		for x in range(width):
			grid[y][x].update_walls()

func get_unvisited_neighbors(pos):
	var neighbors = []

	var directions = [
		Vector2i(0, -1), # top
		Vector2i(1, 0),  # right
		Vector2i(0, 1),  # bottom
		Vector2i(-1, 0)  # left
	]

	for dir in directions:
		var nx = pos.x + dir.x
		var ny = pos.y + dir.y

		if nx >= 0 and ny >= 0 and nx < width and ny < height:
			if not grid[ny][nx].visited:
				neighbors.append(Vector2i(nx, ny))

	return neighbors

func remove_walls(a, b):
	var dx = b.x - a.x
	var dy = b.y - a.y

	if dx == 1:
		grid[a.y][a.x].walls["right"] = false
		grid[b.y][b.x].walls["left"] = false
	elif dx == -1:
		grid[a.y][a.x].walls["left"] = false
		grid[b.y][b.x].walls["right"] = false
	elif dy == 1:
		grid[a.y][a.x].walls["bottom"] = false
		grid[b.y][b.x].walls["top"] = false
	elif dy == -1:
		grid[a.y][a.x].walls["top"] = false
		grid[b.y][b.x].walls["bottom"] = false
