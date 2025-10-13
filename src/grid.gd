extends GridContainer

var matrice : Array = []
var tile_path : PackedScene = preload("res://src/tile/tile.tscn")
var bomb_count : int
var total_bombs : int = 10
var neighbors_directions : Array[Vector2i ] = [
	Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
	Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)
]
enum TYPE {FLAG, BOMB, NONE}
@export var bomb_count_lbl : Label
func _ready() -> void:
	# appeler randomize garantit un résultat pseudo aléatoire
	randomize()
	bomb_count=0
	generate_matrice()
	
func generate_matrice() -> void:
	bomb_count_lbl.text = str(total_bombs)
	# Initialiser la matrice
	var unasigned_tiles : Array = []
	for x in range(columns):
		var line : Array = []
		for y in range(columns):
			# On instantie une case
			var tile : Button = tile_path.instantiate()
			tile.connect("left_click_tile_0", self.left_click_tile_0)
			tile.connect("left_click_tile_bomb", self.left_click_tile_bomb)
			tile.connect("right_click_on", self.right_click_on)
			tile.connect("right_click_off", self.right_click_off)
			tile.set_grid_coords(Vector2i(x, y))
			unasigned_tiles.append(tile)
			
			# Ajouter la case à la scène
			add_child(tile)
			line.append(tile)
			
		# Ajouter la ligne de cases à la matrice
		matrice.append(line)
		
	
	# Mélanger les cases pour garantir un résultat pseudo aléatoire
	unasigned_tiles.shuffle()
	
	# Assigner les bombes à la matrice
	for tile : Tile in unasigned_tiles:
		if bomb_count < total_bombs:
			# Assigner le type BOMB à la case
			tile.set_value(-1)
			bomb_count = bomb_count + 1
			
			var grid_coords = tile.get_grid_coords()
			for neighbor_tile : Tile in get_neighbor_tiles(grid_coords):
				neighbor_tile.increment_nearby_bombs_count()
				neighbor_tile.increment_value()	
				#neighbor_tile.refresh_icon()
		else:
			tile.refresh_memo()
			break
	
	print(matrice)
	
func get_neighbor_tiles(grid_coords : Vector2i) -> Array:
	# Renvoie la liste de tout les voisins
	var neighbor_tiles: Array = []
	for direction : Vector2i in neighbors_directions:
		var neighbor_grid_coords : Vector2i = grid_coords + direction
		var neighbor_tile = get_tile(neighbor_grid_coords)
		if neighbor_tile != null:
			neighbor_tiles.append(neighbor_tile)
	return neighbor_tiles

func get_tile(grid_coords: Vector2i) -> Tile:
	if grid_coords.x < 0 or grid_coords.x >= matrice.size() or \
	   grid_coords.y < 0 or grid_coords.y >= matrice.size():
		return null
	return matrice[grid_coords.x][grid_coords.y]
	
func left_click_tile_0(tile : Tile) -> void:
	var neighbor_tiles : Array = get_neighbor_tiles(tile.get_grid_coords())
	tile.set_type(Tile.TYPE.UNVEILED)
	for neighbor:Tile in neighbor_tiles:
		if neighbor.type!=Tile.TYPE.UNVEILED:
			if neighbor.value==0:
				left_click_tile_0(neighbor)
			else :
				neighbor.set_type(Tile.TYPE.UNVEILED)
				neighbor.refresh_icon()
	tile.refresh_icon()
	
func left_click_tile_bomb(tile : Tile) -> void:
	var neighbor_tiles : Array = get_neighbor_tiles(tile.get_grid_coords())
	tile.set_type(Tile.TYPE.UNVEILED)
	for neighbor:Tile in neighbor_tiles:
		if neighbor.type!=Tile.TYPE.UNVEILED and neighbor.type!=Tile.TYPE.FLAG:
			left_click_tile_bomb(neighbor)
	tile.refresh_icon()
	
func right_click_on() -> void:
	bomb_count=bomb_count-1
	bomb_count_lbl.text = str(bomb_count)
	
func right_click_off() -> void:
	bomb_count=bomb_count+1
	bomb_count_lbl.text = str(bomb_count)
