# main.gd
# ========================================
# Gestion globale du jeu, surtout la fenêtre
# Gère uniquement le mode plein écran (F11)
# ========================================

extends Control

# État du plein écran
var fullscreen: bool = false


# Gère les entrées clavier
func _input(event: InputEvent) -> void:
	# Pour mettre en plein écran
	if Input.is_action_just_pressed("f11"):
		fullscreen = !fullscreen
		var mode = (DisplayServer.WINDOW_MODE_FULLSCREEN
					if fullscreen
					else DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_mode(mode)
