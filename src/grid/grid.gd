extends GridContainer

enum TYPE {FLAG, BOMB, NONE}
@export var bomb_count_lbl : Label
var matrice : Array = []
var tile_path : PackedScene = preload("res://src/tile/tile.tscn")
var bomb_count : int
var total_bombs : int = 10
var neighbors_directions : Array[Vector2i ] = [
	Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
	Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)
]

func _ready() -> void:
	generate_matrice()


func instantiate_tile(x : int, y : int) -> Tile:
	var tile : Button = tile_path.instantiate()
	
	# Connecter la tile à différent signaux
	tile.connect("unveil_tiles_recursive", self.unveil_tiles_recursive)
	tile.connect("left_click_tile_bomb", self.left_click_tile_bomb)
	tile.connect("right_click_on", self.right_click_on)
	tile.connect("right_click_off", self.right_click_off)
	tile.set_grid_coords(Vector2i(x, y))
	
	# Ajouter la case à la scène
	add_child(tile)
	return tile	


func generate_matrice() -> void:
	# Réinitialiser les valeurs et la matrice
	for child in get_children():
		child.queue_free()
	matrice.clear()
	set_bomb_count(0)
	
	# Initialiser la matrice
	var unasigned_tiles : Array = []
	for x : int in range(columns):
		var line : Array = []
		for y : int in range(columns):
			var tile : Tile = instantiate_tile(x, y)
			unasigned_tiles.append(tile)
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
			set_bomb_count(bomb_count + 1)
			
			var grid_coords = tile.get_grid_coords()
			for neighbor_tile : Tile in get_neighbor_tiles(grid_coords):
				neighbor_tile.increment_nearby_bombs_count()
				neighbor_tile.increment_value()	
		else:
			tile.refresh_front_icon()
			break
	
	
func get_neighbor_tiles(grid_coords : Vector2i) -> Array:
	# Renvoie la liste de tout les voisins d'une tile
	var neighbor_tiles: Array = []
	for direction : Vector2i in neighbors_directions:
		var neighbor_grid_coords : Vector2i = grid_coords + direction
		var neighbor_tile = get_tile(neighbor_grid_coords)
		
		if neighbor_tile != null:
			neighbor_tiles.append(neighbor_tile)
	return neighbor_tiles


func get_tile(grid_coords: Vector2i) -> Tile:
	# On vérifie que la tile n'est pas en dehors de la matrice
	if grid_coords.x < 0 or grid_coords.x >= matrice.size() \
		or grid_coords.y < 0 or grid_coords.y >= matrice.size():
		return null
	return matrice[grid_coords.x][grid_coords.y]
	
	
func unveil_tiles_recursive(tile : Tile) -> void:
	var neighbor_tiles : Array = get_neighbor_tiles(tile.get_grid_coords())
	tile.set_type(Tile.TYPE.UNVEILED)
	tile.refresh_icon()
	if tile.value != 0:
		return
	
	# Si la case est vide, on propage le dévoilage des tiles aux autres voisins
	for neighbor:Tile in neighbor_tiles:
		if neighbor.type != Tile.TYPE.UNVEILED:
			unveil_tiles_recursive(neighbor)
	
	
	
func left_click_tile_bomb() -> void:
	for x : int in range(columns):
		for y : int in range(columns):
			var coords_tile : Vector2i = Vector2i(x, y)
			var tile : Tile =  get_tile(coords_tile)
			if tile.value == -1 and tile.type != Tile.TYPE.FLAG:
				tile.set_type(Tile.TYPE.UNVEILED)
				tile.refresh_icon()
	
	
func set_bomb_count(value) -> void:
	bomb_count = value
	bomb_count_lbl.text = str(bomb_count)	

	
func right_click_on() -> void:
	set_bomb_count(bomb_count - 1)
	
	
func right_click_off() -> void:
	set_bomb_count(bomb_count + 1)
		
	
func _on_reset_btn_pressed() -> void:
	generate_matrice()
