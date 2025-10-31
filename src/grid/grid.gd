# src/grid/grid.gd
# ========================================
# Gestion de la grille et des interactions grille-cases
# Gère :
# - Génération de la grille
# - Placement aléatoire des bombes
# - Dévoilement récursif
# - Victoire / Défaite
# - Compteur de bombes restantes
# ========================================

class_name Grid
extends GridContainer

# --- Labels utilisés pour l'interface --------------------------------------------------------------------------------
@export var bomb_count_lbl: Label      # Affiche le nombre de bombes restantes (selon le nombre de drapeaux placés)
@export var timer_lbl: TimerLbl        # Chronomètre
@export var game_ended_lbl: Label      # Affiche le texte de fin de partie (victoire ou défaite)

# --- Variables --------------------------------------------------------------------------------
# Grille en 2 dimensions qui contient les tiles
var matrice: Array[Array] = []

# Scène de tile à instancier
var tile_path: PackedScene = preload("res://src/tile/tile.tscn")

# Bombes restantes à "drapeauter"
var bomb_count: int = 0

# Nombre TOTAL de bombes dans la partie (fixe)
var total_bombs: int = 10

# Cases encore cachées, victoire quand veiled_tile_cpt == total_bombs (en gros quand il reste autant de bombes que de cases non dévoilées)
var veiled_tile_cpt: int = 0

# Sert à savoir si la partie a commencé ou non, sert à gérer le timer
var game_started: bool = false

# Directions des voisins
var neighbors_directions: Array[Vector2i] = [
	Vector2i(1, 0), Vector2i(-1, 0),
	Vector2i(0, 1), Vector2i(0, -1),
	Vector2i(1, 1), Vector2i(1, -1),
	Vector2i(-1, 1), Vector2i(-1, -1)
]


# --- Initialisation --------------------------------------------------------------------------------

func _ready() -> void:
	# Générer la matrice lorsqu'on lance le jeu
	_generate_matrice()

# Méthode appelée lorsqu'on clique sur le bouton réinitialiser
# Réinitialise la matrice
func _on_reset_btn_pressed() -> void:
	_generate_matrice()


# --- Génération de la grille --------------------------------------------------------------------------------

# Génère une nouvelle matrice, peut être appelé pour écraser l'ancienne matrice lorsqu'on recommence une partie 
func _generate_matrice() -> void:
	# Vider l'ancienne grille
	for child in get_children():
		child.queue_free()
	
	# Réinitialiser les valeurs et la matrice
	game_started = false
	matrice.clear()
	_set_bomb_count(total_bombs)
	veiled_tile_cpt = columns * columns
	game_ended_lbl.text = ""
	timer_lbl.text = "00:00"
	
	# Initialiser la matrice et les tiles dans la matrice
	var unasigned_tiles: Array[Tile] = []
	for x in range(columns):
		var line: Array[Tile] = []
		for y in range(columns):
			var tile: Tile = instantiate_tile(x, y)
			unasigned_tiles.append(tile)
			line.append(tile)
		# Ajouter la ligne de cases à la matrice
		matrice.append(line)
	
	# On mélange comme ça on est surs d'avoir un placement de bombes complètement aléatoire
	unasigned_tiles.shuffle()
	
	# Assigner les bombes à la matrice
	for tile in unasigned_tiles:
		if bomb_count < total_bombs:
			# Assigner le type BOMB à la case
			tile.set_value(-1)
			_set_bomb_count(bomb_count + 1)
			
			# Incrémenter les voisins
			var coords = tile.get_grid_coords()
			for neighbor in get_neighbor_tiles(coords):
				neighbor.increment_value()
		else:
			# Case sûre → affiche l'icône cachée
			tile.refresh_front_icon()
			break


# --- Création de tiles --------------------------------------------------------------------------------

# Instantie une tile (case) et l'ajoute à la scène
func instantiate_tile(x: int, y: int) -> Tile:
	# Nouvelle instance de tile
	var tile: Tile = tile_path.instantiate() as Tile
	
	# Connecter la tile à différent signaux
	tile.connect("unveil_tiles_recursive", Callable(self, "unveil_tiles_recursive"))
	tile.connect("left_click_on_bomb", Callable(self, "left_click_on_bomb"))
	tile.connect("right_click_on", Callable(self, "right_click_on"))
	tile.connect("right_click_off", Callable(self, "right_click_off"))
	tile.connect("game_started", Callable(self, "on_game_started"))
	tile.connect("tile_clicked", Callable(self, "tile_clicked"))
	
	# On définit les coordonnées de la tile
	tile.set_grid_coords(Vector2i(x, y))
	
	# Ajouter la case à la scène
	add_child(tile)
	return tile


# --- Fonctions utilitaires --------------------------------------------------------------------------------

# Met à jour le compteur et le label
func _set_bomb_count(value: int) -> void:
	bomb_count = value
	bomb_count_lbl.text = str(bomb_count)

# Retourne les 8 voisins valides (ou moins sur les bords)
func get_neighbor_tiles(grid_coords: Vector2i) -> Array[Tile]:
	var neighbors: Array[Tile] = []
	for dir in neighbors_directions:
		var neighbor_coords = grid_coords + dir
		var tile = get_tile(neighbor_coords)
		if tile != null:
			neighbors.append(tile)
	return neighbors

# Récupère une tile par coordonnées (ou null si hors grille)
func get_tile(grid_coords: Vector2i) -> Tile:
	# On vérifie que la tile n'est pas en dehors de la matrice
	if (grid_coords.x < 0 or grid_coords.x >= matrice.size() or
		grid_coords.y < 0 or grid_coords.y >= matrice.size()):
		return null
	return matrice[grid_coords.x][grid_coords.y]


# --- Mécaniques --------------------------------------------------------------------------------

# Méthode appelée lorsque l'on révèle une case vide
# Révèle les cases vides et leurs voisins de manière récursive
func unveil_tiles_recursive(tile: Tile) -> void:
	veiled_tile_cpt -= 1
	tile.set_type(Tile.TYPE.UNVEILED)
	tile.refresh_icon()
	
	# Arrête l'appel si la case est un chiffre
	if tile.value != 0:
		return
	
	# Si la case est vide, on propage le dévoilage des tiles aux autres voisins
	for neighbor in get_neighbor_tiles(tile.get_grid_coords()):
		if neighbor.type != Tile.TYPE.UNVEILED:
			unveil_tiles_recursive(neighbor)

# Méthode appelée lorsqu'on clique sur une bombe
# Révèle les bombes qui ne sont pas marquées par un drapeau et met fin à la partie
func left_click_on_bomb() -> void:
	game_ended_lbl.text = "Défaite ):"
	for x in range(columns):
		for y in range(columns):
			var tile = get_tile(Vector2i(x, y))
			# Révéler les bombes non marquées
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
	if game_started:
		return
	game_started = true
	timer_lbl.set_is_game_ended(false)

# Méthode appelée lorsque l'on perds ou gagne la partie
# Mets fin au timer et empêche de continuer à jouer
func on_game_ended() -> void:
	timer_labl.set_is_game_ended(true)
	for tile in get_children():
		tile.disable_clics = true
		tile.disabled = true  # pour l'apparence
