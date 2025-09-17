extends GridContainer

var matrice : Array
var tile_path : PackedScene = preload("res://src/tile/tile.tscn")
enum UPPER_LAYER {FLAG, BOMB, QUESTION_MARK, NONE}

func _ready() -> void:
	# appeler randomize garantit un résultat pseudo aléatoire
	randomize()
	
	for x in range(columns):
		for y in range(columns):
			var tile : Button = tile_path.instantiate()
			add_child(tile)
			matrice.append(tile)
	print(matrice)
	
	matrice.shuffle()
