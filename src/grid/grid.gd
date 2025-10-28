class_name Grid
extends GridContainer

enum TYPE {FLAG, BOMB, NONE}
@export var bomb_count_lbl : Label
@export var timer_lbl : Label
@export var game_ended_lbl: Label
var matrice : Array = []
var tile_path : PackedScene = preload("res://src/tile/tile.tscn")
var bomb_count : int
var total_bombs : int = 10
var veiled_tile_cpt : int
var game_started: bool = false
var neighbors_directions : Array[Vector2i ] = [
	Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
	Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)
]

# Fonction Built in de Godot appelée lorsque le noeud est ajouté à la scène
# (au démarage de l'application)
func _ready() -> void:
	# Générer la matrice lorsqu'on lance le jeu
	_generate_matrice()

# Méthode appelée lorsqu'on clique sur le bouton réinitialiser
# Réinitialise la matrice
func _on_reset_btn_pressed() -> void:
	_generate_matrice()


# Génère une nouvelle matrice, peut être appelé pour écraser l'ancienne matrice lorsqu'on recommence une partie 
func _generate_matrice() -> void:
	# Libérer les enfants (les tiles)
	for child : Tile in get_children():
		child.queue_free()
		
	# Réinitialiser les valeurs et la matrice
	game_started = false
	matrice.clear()
	_set_bomb_count(0)
	veiled_tile_cpt = columns * columns
	game_ended_lbl.text = ""
	timer_lbl.text = "00:00"

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
			_set_bomb_count(bomb_count + 1)
			
			var grid_coords = tile.get_grid_coords()
			for neighbor_tile : Tile in get_neighbor_tiles(grid_coords):
				neighbor_tile.increment_nearby_bombs_count()
				neighbor_tile.increment_value()	
		else:
			tile.refresh_front_icon()
			break
	
	
# Instantie une tile (case) et l'ajoute à la scène
func instantiate_tile(x : int, y : int) -> Tile:
	# Nouvelle instance de tile
	var tile : Button = tile_path.instantiate()
	
	# Connecter la tile à différent signaux
	tile.connect("unveil_tiles_recursive", self.unveil_tiles_recursive)
	tile.connect("left_click_on_bomb", self.left_click_on_bomb)
	tile.connect("right_click_on", self.right_click_on)
	tile.connect("right_click_off", self.right_click_off)
	tile.connect("game_started", self.on_game_started)
	tile.connect("tile_clicked", self.tile_clicked)
	
	# On définit les coordonnées de la tile
	tile.set_grid_coords(Vector2i(x, y))
	
	# Ajouter la case à la scène
	add_child(tile)
	return tile	
		
# --- Fonctions utilitaires --------------------------------------------------------------------------------

func _set_bomb_count(value) -> void:
	bomb_count = value
	bomb_count_lbl.text = str(bomb_count)	

	
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
	

# Méthode appelée lorsque l'on révèle une case vide
# Révèle les cases vides et leurs voisins de manière récursive
func unveil_tiles_recursive(tile : Tile) -> void:
	var neighbor_tiles : Array = get_neighbor_tiles(tile.get_grid_coords())
	veiled_tile_cpt -= 1
	tile.set_type(Tile.TYPE.UNVEILED)
	tile.refresh_icon()
	if tile.value != 0:
		return
	
	# Si la case est vide, on propage le dévoilage des tiles aux autres voisins
	for neighbor:Tile in neighbor_tiles:
		if neighbor.type != Tile.TYPE.UNVEILED:
			unveil_tiles_recursive(neighbor)
	

# Méthode appelée lorsqu'on clique sur une bombe
# Révèle les bombes qui ne sont pas marquées par un drapeau et met fin à la partie
func left_click_on_bomb() -> void:
	game_ended_lbl.text = "Défaite ):"
	for x : int in range(columns):
		for y : int in range(columns):
			var coords_tile : Vector2i = Vector2i(x, y)
			var tile : Tile =  get_tile(coords_tile)
			if tile.value == -1 and tile.type != Tile.TYPE.FLAG:
				tile.set_type(Tile.TYPE.UNVEILED)
				tile.refresh_icon()
				on_game_ended()
	
# Méthode appelée lors d'un clic droit sur une tile	non retournée
# Augmente le compteur de bombes de 1
func right_click_on() -> void:
	_set_bomb_count(bomb_count - 1)
	
# Méthode appelée lors d'un clic droit sur une tile	non retournée et avec un drapeau
# Réduit le compteur de bombes de 1
func right_click_off() -> void:
	_set_bomb_count(bomb_count + 1)
	
# Méthode appelé à chaque clic sur une tile
# Mets fin à la partie si toutes les cases ont été retourné sauf les bombes
func tile_clicked() -> void:
	# on vérifie si la partie est terminée
	if veiled_tile_cpt == total_bombs:
		on_game_ended()
		game_ended_lbl.text = "Victoire :)"
		

# Méthode appelée lorsque l'on clique sur une tile pour la première fois de la partie
# Démarre le timer
func on_game_started() -> void:
	if game_started: return
	game_started = true
	timer_lbl.set_is_game_ended(false)
	
# Méthode appelée lorsque l'on perds ou gagne la partie
# Mets fin au timer et empêche de continuer à jouer
func on_game_ended() -> void:
	timer_lbl.set_is_game_ended(true)
	for tile : Tile in get_children():
		tile.disable_clics = true
		tile.disabled = true # pour l'apparence
