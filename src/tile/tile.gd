# src/tile/tile.gd
# ========================================
# Classe des cases du jeu
# Gère :
# - L'affichage (cachée, drapeau, bombe, nombre)
# - Les clics gauche/droit
# - L'émission de signaux vers Grid
# ========================================

class_name Tile
extends Button

# --- Signaux ---------------------------------------------------------------------------
# Émis quand on pose un drapeau (clic droit sur case cachée)
signal right_click_on
# Émis quand on retire un drapeau
signal right_click_off
# Émis pour déclencher le dévoilement récursif (clic gauche sur case vide)
signal unveil_tiles_recursive(tile: Tile)
# Émis quand on clique gauche sur une bombe → défaite
signal left_click_on_bomb
# Émis au premier clic gauche de la partie → démarre le timer
signal game_started
# Émis à chaque clic (gauche ou droit) → vérifie victoire
signal tile_clicked


# --- Enums ---------------------------------------------------------------------------
# États visuels et logiques d'une case
# NONE     → cachée, sans drapeau
# FLAG     → cachée avec drapeau
# UNVEILED → révélée (bombe ou nombre)
# BOMB     → interne seulement (value = -1), pas un état visuel
enum TYPE {FLAG, BOMB, NONE, UNVEILED}


# --- Variables ---------------------------------------------------------------------------
# État actuel VISIBLE (couche supérieure) de la case (NONE / FLAG / UNVEILED)
var type: TYPE = TYPE.NONE

# Valeur interne INVISIBLE (couche inférieure) de la case :
# -1 → bombe
#  0 → case vide (déclenche récursion)
#  1 à 8 → nombre de bombes adjacentes
var value: int = 0

# Coordonnées dans la grille (x, y)
var grid_coords: Vector2i = Vector2i(0, 0)

# Bloque le jeu quand on gagne ou perd (jusqu'à réinitialiser la partie)
var disable_clics: bool = false


# --- Méthodes privées ---------------------------------------------------------------------------
# Méthode integrée de Godot appelée quand la souris survole la case
# Gère les clics gauche et droit :
# - Clic gauche : dévoile la case (et ses voisines si nécessaire).
# - Clic droit : place ou retire un drapeau, si la case n'est pas déjà dévoilée.
func _gui_input(event: InputEvent) -> void:
	if disable_clics:
		return  # Bloque toute intéraction quand la partie est finie
	
	if not (event is InputEventMouseButton and event.pressed):
		return  # Seul les clics de souris sont autorisés, pas le clavier
	
	match event.button_index:
		MOUSE_BUTTON_LEFT:
			# Clic gauche uniquement sur case non dévoilée
			if type != TYPE.NONE:
				return
			
			emit_signal("game_started")  # On démarre le timer
			refresh_icon()  # Actualise l'apparence de la case cliquée
			
			if value == -1:
				# Activation de la défaite parce qu'une bombe a été cliquée
				emit_signal("left_click_on_bomb")
			else:
				# Dévoilement récursif des cases si non-bombe (on imite le démineur, on dévoile les cases voisines qui valent 0 récursivement)
				emit_signal("unveil_tiles_recursive", self)
			
			emit_signal("tile_clicked")  # Vérifie victoire
		
		MOUSE_BUTTON_RIGHT:
			# Clic droit uniquement sur case non dévoilée
			if type == TYPE.UNVEILED:
				return
			put_flag()  # Alterne entre NONE et FLAG

# --- Get-Set ---------------------------------------------------------------------------
func get_type() -> TYPE:
	return type

func set_type(new_type: TYPE) -> void:
	type = new_type
	refresh_front_icon()  # Actualisation visuelle du plateau

func get_value() -> int:
	return value

func set_value(new_value: int) -> void:
	value = new_value

func get_grid_coords() -> Vector2i:
	return grid_coords

func set_grid_coords(coords: Vector2i) -> void:
	grid_coords = coords

# Incrémente la valeur (nombre affiché) par rapport aux nombre de bombes voisines, sauf si c'est une bombe
func increment_value() -> void:
	if value == -1:
		return  # Si la case est une bombe, on ne fait rien
	value += 1


# --- Gestion Affichage ---------------------------------------------------------------------------
# Actualisation visuelle des cases dévoilées
func refresh_icon() -> void:
	var icon_name: String
	match value:
		-1:  icon_name = "bomb"           # Bombe révélée
		0:   icon_name = "hidden_tile"    # Case vide
		1:   icon_name = "tile_1"
		2:   icon_name = "tile_2"
		3:   icon_name = "tile_3"
		4:   icon_name = "tile_4"
		5:   icon_name = "tile_5"
		6:   icon_name = "tile_6"
		7:   icon_name = "tile_7"
		8:   icon_name = "tile_8"
	
	icon = load("res://assets/sprites/" + icon_name + ".png")

# Met à jour l'icône selon l'état (cachée ou drapeau)
# Un tile retourné n'a pas de texture à rafraichir
func refresh_front_icon() -> void:
	if type == TYPE.UNVEILED:
		return  # Les cases dévoilées utilisent refresh_icon()
	
	var icon_name: String
	match type:
		TYPE.FLAG: icon_name = "flag"
		TYPE.NONE: icon_name = "tile"
	
	icon = load("res://assets/sprites/" + icon_name + ".png")


# --- Actions du joueur ---------------------------------------------------------------------------
# Alterne entre pose et retrait de drapeau
func put_flag() -> void:
	if type == TYPE.NONE:
		set_type(TYPE.FLAG)
		emit_signal("right_click_on")  # Met à jour le compteur de bombes affiché dans le jeu
	elif type == TYPE.FLAG:
		set_type(TYPE.NONE)
		emit_signal("right_click_off")
