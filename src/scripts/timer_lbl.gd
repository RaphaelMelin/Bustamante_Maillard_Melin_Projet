# src/timer_lbl.gd
# ========================================
# TIMERLBL : Affiche un chronomètre MM:SS
# Démarre au premier clic, s'arrête à la fin de la partie (victoire ou défaite, peu importe)
# ========================================

class_name TimerLbl
extends Label

# Temps écoulé en secondes
var timer: float = 0.0

# true = chronomètre actif
var is_running: bool = false


# Appelé 60 fois par seconde
func _process(delta: float) -> void:
	if not is_running:
		return
	
	# Incrémente le timer
	timer += delta
	
	# Formate (en MM:SS) + Affiche le timer
	var minutes = int(timer) / 60
	var seconds = int(timer) % 60
	text = "%02d:%02d" % [minutes, seconds]


# Appelé à la fin ou au début d'une partie
# Initialise le timer à 0 et le démarre ou l'arrête
func set_is_game_ended(is_ended: bool) -> void:
	is_running = !is_ended
	if is_running:
		timer = 0.0
