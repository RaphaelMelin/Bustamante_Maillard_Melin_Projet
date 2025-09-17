extends GridContainer

var matrice : Array = []
var tile_path : PackedScene = preload("res://src/tile/tile.tscn")
var bomb_counter : int
var neighbors_directions : Array[Vector2i ] = [
	Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
	Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)
]
enum TYPE {FLAG, BOMB, QUESTION_MARK, NONE}

func _ready() -> void:
	# appeler randomize garantit un résultat pseudo aléatoire
	randomize()
	bomb_counter=0
	for x in range(columns):
		var line : Array = []
		for y in range(columns):
			var tile : Button = tile_path.instantiate()
			if bomb_counter<10:
				tile.set_type(TYPE.BOMB)
				bomb_counter=bomb_counter+1
			add_child(tile)
			line.append(tile)
		matrice.append(line)
	matrice.shuffle()
	print(matrice)
	
func get_neighbor_tiles(cell : Vector2i) -> Array:
	# Renvoie la liste de tout les voisins
	var neighbors: Array = []
	for dir : Vector2i in neighbors_directions:
		var neighbor : Vector2i = cell + dir
		neighbors.append(neighbor)
	return neighbors
