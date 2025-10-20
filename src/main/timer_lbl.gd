extends Label

var timer: float = 0.0
var is_game_ended : bool = true

func _process(delta: float) -> void:
	if is_game_ended:
		return
	timer += delta
	var minutes = int(timer) / 60
	var seconds = int(timer) % 60
	text = "%02d:%02d" % [minutes, seconds]  # e.g., 01:23

func on_game_ended() -> void:
	is_game_ended = true

func set_is_game_ended(value : bool) -> void:
	print("test")
	is_game_ended = value
	if value==false:
		timer=0.0
