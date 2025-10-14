extends Label

var timer: float = 0.0

func _process(delta: float) -> void:
	timer += delta
	var minutes = int(timer) / 60
	var seconds = int(timer) % 60
	text = "%02d:%02d" % [minutes, seconds]  # e.g., 01:23
