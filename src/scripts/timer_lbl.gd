class_name TimerLbl
extends Label

var timer: float = 0.0
var is_game_ended : bool = true


# Méthode built-in de godot appelée 60 fois par secondes
func _process(delta: float) -> void:
	if is_game_ended:
		return
	
	# Incrémente le timer
	timer += delta
	
	# Affiche le timer
	var minutes = int(timer) / 60
	var seconds = int(timer) % 60
	text = "%02d:%02d" % [minutes, seconds]  # exemple: 00:59

# Méthode appelée à la fin ou au début d'une partie
# Initialise le timer à 0 et le démarre ou l'arrête
func set_is_game_ended(value : bool) -> void:
	is_game_ended = value
	if value == false:
		timer = 0.0
