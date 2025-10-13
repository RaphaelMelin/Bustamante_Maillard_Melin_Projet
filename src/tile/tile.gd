extends Button
	
class_name Tile
signal left_click
signal right_click
var type : TYPE = TYPE.NONE
enum TYPE {FLAG, BOMB, NONE, UNVEILED}

var value : int = 0
var nearby_bombs_count = 0
var grid_coords : Vector2i

signal right_click_tile_0
signal right_click_tile_bomb
# Méthodes privées

func _ready():
	connect("gui_input", _on_Button_gui_input)

func _on_Button_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				print("clic gauche")
				emit_signal("left_click")
				if type==TYPE.NONE:
					refresh_icon()
					if value==0:
						emit_signal("right_click_tile_0", self)
					if value==-1:
						emit_signal("right_click_tile_bomb", self)
			MOUSE_BUTTON_RIGHT:
				print("clic droit")
				emit_signal("right_click")
				if type!=TYPE.UNVEILED:
					put_memo()


# Méthodes publiques

func get_type() -> TYPE:
	return type

func set_type(type_):
	type = type_
	refresh_memo()
	
func get_value() -> int:
	return value	

func set_value(value_ : int) -> void:
	value = value_	
	
	
func refresh_icon() -> void:
	#match type_:
	#	TYPE.BOMB:
	#		icon_name = "bomb"
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

func put_memo() -> void :
	if type==TYPE.NONE:
		set_type(TYPE.FLAG)
	elif type==TYPE.FLAG:
		set_type(TYPE.NONE)

func refresh_memo() -> void:
	var icon_name : String
	match type:
		TYPE.FLAG : icon_name = "flag"
		TYPE.NONE : icon_name = "tile"
	
	icon = load("res://assets/sprites/" + icon_name + ".png")
