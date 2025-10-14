class_name Tile

extends Button
	
signal left_click
signal right_click_on
signal right_click_off
signal unveil_tiles_recursive
signal left_click_tile_bomb
signal game_ended
signal game_started

enum TYPE {FLAG, BOMB, NONE, UNVEILED}
var type : TYPE = TYPE.NONE

var value : int = 0
var nearby_bombs_count = 0
var grid_coords : Vector2i

# Méthodes privées

func _ready():
	connect("gui_input", _on_Button_gui_input)


func _on_Button_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				print("clic gauche")
				if type==TYPE.NONE:
					emit_signal("game_started")
					refresh_icon()
					if value==0:
						emit_signal("unveil_tiles_recursive", self)
					if value==-1:
						emit_signal("left_click_tile_bomb")
			MOUSE_BUTTON_RIGHT:
				print("clic droit")
				if type!=TYPE.UNVEILED:
					put_flag()


# Méthodes publiques

func get_type() -> TYPE:
	return type


func set_type(type_):
	type = type_
	refresh_front_icon()

	
func get_value() -> int:
	return value	


func set_value(value_ : int) -> void:
	value = value_	
	
	
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


func get_grid_coords() -> Vector2i:
	return grid_coords


func set_grid_coords(grid_coords_ : Vector2i) -> void:
	grid_coords = grid_coords_


func increment_nearby_bombs_count() -> void:
	nearby_bombs_count += 1
	
func increment_value() -> void:
	# Si la case est une bombre, on ne fait rien
	if value == -1: return
	value += 1


func put_flag() -> void :
	if type==TYPE.NONE:
		set_type(TYPE.FLAG)
		emit_signal("right_click_on")
	elif type==TYPE.FLAG:
		set_type(TYPE.NONE)
		emit_signal("right_click_off")


func refresh_front_icon() -> void:
	# Une tile retourné n'a pas de texture avant
	if type == TYPE.UNVEILED:
		return
	
	var icon_name : String
	match type:
		TYPE.FLAG : icon_name = "flag"
		TYPE.NONE : icon_name = "tile"
	
	icon = load("res://assets/sprites/" + icon_name + ".png")
