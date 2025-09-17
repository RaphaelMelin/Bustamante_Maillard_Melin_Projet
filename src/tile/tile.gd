extends Button
	
	
signal left_click
signal right_click
var type : TYPE
enum TYPE {FLAG, BOMB, QUESTION_MARK, NONE}

func _ready():
	connect("gui_input", _on_Button_gui_input)
	if type == TYPE.BOMB:
		icon=preload("res://assets/sprites/bomb.png")

func set_type(type_):
	type = type_

func get_type():
	return type

func _on_Button_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				print("clic gauche")
				emit_signal("left_click")
			MOUSE_BUTTON_RIGHT:
				print("clic droit")
				emit_signal("right_click")
				
				
