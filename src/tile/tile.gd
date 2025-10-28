class_name Tile

extends Button
	
signal right_click_on
signal right_click_off
signal unveil_tiles_recursive
signal left_click_on_bomb
signal game_started
signal tile_clicked

enum TYPE {FLAG, BOMB, NONE, UNVEILED}
var type : TYPE = TYPE.NONE

var value : int = 0
var nearby_bombs_count = 0
var grid_coords : Vector2i
var disable_clics: bool = false

# --- Méthodes privées ---------------------------------------------------------------------------
# Méthode integrée de Godot appelée quand la souris survole la case
# Gère les clics gauche et droit :
# - Clic gauche : dévoile la case (et ses voisines si nécessaire).
# - Clic droit : place ou retire un drapeau, si la case n'est pas déjà dévoilée.
func _gui_input(event):
	if disable_clics: return
	
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				if type == TYPE.NONE:
					emit_signal("game_started")
					refresh_icon()
					if value == -1:
						emit_signal("left_click_on_bomb")
					else:
						emit_signal("unveil_tiles_recursive", self)
				emit_signal("tile_clicked")
			
			MOUSE_BUTTON_RIGHT:
				if type != TYPE.UNVEILED:
					put_flag()


# --- Méthodes getter et setter ------------------------------------------------------------------------------------

# Type ---------------------
func get_type() -> TYPE:
	return type

func set_type(type_):
	type = type_
	refresh_front_icon()

	
# Value ---------------------
func get_value() -> int:
	return value	

func set_value(value_ : int) -> void:
	value = value_	
	
	
# Grid Coords ---------------------
func get_grid_coords() -> Vector2i:
	return grid_coords

func set_grid_coords(grid_coords_ : Vector2i) -> void:
	grid_coords = grid_coords_


# Increment ---------------------
func increment_nearby_bombs_count() -> void:
	nearby_bombs_count += 1
	
func increment_value() -> void:
	# Si la case est une bombe, on ne fait rien
	if value == -1: return
	value += 1


# --- Refresh l'icon de la tile -------------------------------------
func refresh_icon() -> void:
	var icon_name : String
	match value:
		-1: icon_name = "bomb"
		0: icon_name = "hidden_tile"
		1: icon_name = "tile_1"
		2: icon_name = "tile_2"
		3: icon_name = "tile_3"
		4: icon_name = "tile_4"
		5: icon_name = "tile_5"
		6: icon_name = "tile_6"
		7: icon_name = "tile_7"
		8: icon_name = "tile_8"
			
	icon = load("res://assets/sprites/" + icon_name + ".png")


func refresh_front_icon() -> void:
	# Une tile retourné n'a pas de texture à rafraichir
	if type == TYPE.UNVEILED: return
	
	var icon_name : String
	match type:
		TYPE.FLAG : icon_name = "flag"
		TYPE.NONE : icon_name = "tile"
	
	icon = load("res://assets/sprites/" + icon_name + ".png")


# Méthode appelée lors d’un clic droit.
# Si la case est vide, un drapeau est posé.
# Si un drapeau est déjà présent, il est retiré.
func put_flag() -> void :
	if type==TYPE.NONE:
		set_type(TYPE.FLAG)
		emit_signal("right_click_on")
	elif type==TYPE.FLAG:
		set_type(TYPE.NONE)
		emit_signal("right_click_off")
