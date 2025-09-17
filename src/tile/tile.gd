extends Button
	
	
signal left_click
signal right_click

func _ready():
	connect("gui_input", _on_Button_gui_input)

func _on_Button_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				print("clic gauche")
				emit_signal("left_click")
			MOUSE_BUTTON_RIGHT:
				print("clic droit")
				emit_signal("right_click")
				
				
