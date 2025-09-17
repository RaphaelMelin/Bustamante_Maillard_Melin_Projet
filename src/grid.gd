extends BoxContainer

var matrice : Array
var button_path = preload("res://src/button/button.tscn")

enum UPPER_LAYER {FLAG, BOMB, QUESTION_MARK, NONE}

func _ready() -> void:
	# appeler randomize garantit un résultat pseudo aléatoire
	randomize()
	
	for x in range(9):
		for y in range(9):
			var button = button_path.instantiate()
			add_child(button)
			matrice.append(button)
	print(matrice)
	
	matrice.shuffle()
