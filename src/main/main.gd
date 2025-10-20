extends Control


var fullscreen : bool = false

func _ready() -> void:
	print("Hello world")

func _input(_event : InputEvent) -> void:
	# Pour mettre en plein écran
	if Input.is_action_just_pressed("f11"):
		if fullscreen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		fullscreen = !fullscreen
