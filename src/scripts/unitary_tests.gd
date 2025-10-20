extends GdUnitTestSuite

# Classe de test pour le GridContainer du démineur
# Nécessite GdUnit4 : https://github.com/MikeSchulze/gdUnit4

var grid: Grid

## Fonction appelée automatiquement au début de chaque test
func before_test():
	grid = auto_free(preload("res://src/grid/grid.tscn").instantiate())
	add_child(grid)	
	if grid.bomb_count_lbl == null:
		grid.bomb_count_lbl = auto_free(Label.new())

 
# ===== TESTS D'INITIALISATION =====

func test_matrice_initialization():
	# Tester que la matrice se génère correctement
	grid.generate_matrice()
	assert_int(grid.matrice.size()).is_equal(grid.columns)
	assert_int(grid.matrice[0].size()).is_equal(grid.columns)
	

func test_bomb_count_initialization():
	# Vérifier que le compteur de bombes s'initialise correctement
	grid.generate_matrice()	
	assert_int(grid.bomb_count).is_equal(grid.total_bombs)


func test_total_bombs_count():
	# Vérifier que le nombre total de bombes est correct
	grid.generate_matrice()
	
	var bombs_found = 0
	for x in range(grid.columns):
		for y in range(grid.columns):
			var tile = grid.get_tile(Vector2i(x, y))
			if tile.value == -1:
				bombs_found += 1
	
	assert_int(bombs_found).is_equal(grid.total_bombs)

# ===== TESTS GET_TILE =====

func test_get_tile_valid_coords():
	# Tester la récupération d'une tile avec des coordonnées valides
	grid.generate_matrice()
	
	var tile = grid.get_tile(Vector2i(0, 0))
	assert_object(tile).is_not_null()


func test_get_tile_invalid_negative_coords():
	# Tester avec des coordonnées négatives
	grid.generate_matrice()
	
	var tile = grid.get_tile(Vector2i(-1, 0))
	assert_object(tile).is_null()


func test_get_tile_invalid_out_of_bounds():
	# Tester avec des coordonnées hors limites
	grid.generate_matrice()
	
	var tile = grid.get_tile(Vector2i(grid.columns, grid.columns))
	assert_object(tile).is_null()

# ===== TESTS GET_NEIGHBOR_TILES =====

func test_get_neighbor_tiles_corner():
	# Tester les voisins d'une case dans un coin (devrait avoir 3 voisins)
	grid.generate_matrice()
	
	var neighbors = grid.get_neighbor_tiles(Vector2i(0, 0))
	assert_int(neighbors.size()).is_equal(3)


func test_get_neighbor_tiles_edge():
	# Tester les voisins d'une case sur un bord (devrait avoir 5 voisins)
	grid.generate_matrice()
	
	var neighbors = grid.get_neighbor_tiles(Vector2i(0, 1))
	assert_int(neighbors.size()).is_equal(5)


func test_get_neighbor_tiles_center():
	# Tester les voisins d'une case au centre (devrait avoir 8 voisins)
	grid.generate_matrice()
	
	var center = Vector2i(grid.columns / 2, grid.columns / 2)
	var neighbors = grid.get_neighbor_tiles(center)
	assert_int(neighbors.size()).is_equal(8)


func test_get_neighbor_tiles_all_valid():
	# Vérifier que tous les voisins retournés sont valides
	grid.generate_matrice()
	
	var neighbors = grid.get_neighbor_tiles(Vector2i(1, 1))
	
	for neighbor in neighbors:
		assert_object(neighbor).is_not_null()
		assert_bool(neighbor is Tile).is_true()

# ===== TESTS SET_BOMB_COUNT =====

func test_set_bomb_count_updates_value():
	# Vérifier que set_bomb_count met à jour la valeur
	grid.set_bomb_count(5)	
	assert_int(grid.bomb_count).is_equal(5)


func test_set_bomb_count_updates_label():
	# Vérifier que le label est mis à jour
	grid.set_bomb_count(7)
	
	assert_str(grid.bomb_count_lbl.text).is_equal("7")


func test_set_bomb_count_zero():
	# Tester avec la valeur 0
	grid.set_bomb_count(0)
	
	assert_int(grid.bomb_count).is_equal(0)
	assert_str(grid.bomb_count_lbl.text).is_equal("0")


func test_set_bomb_count_negative():
	# Tester avec une valeur négative
	grid.set_bomb_count(-3)
	
	assert_int(grid.bomb_count).is_equal(-3)
	assert_str(grid.bomb_count_lbl.text).is_equal("-3")

# ===== TESTS RIGHT_CLICK =====

func test_right_click_on_decrements():
	# Vérifier que right_click_on décrémente le compteur
	grid.set_bomb_count(10)
	grid.right_click_on()	
	assert_int(grid.bomb_count).is_equal(9)


func test_right_click_off_increments():
	# Vérifier que right_click_off incrémente le compteur
	grid.set_bomb_count(10)
	grid.right_click_off()
	assert_int(grid.bomb_count).is_equal(11)


func test_right_click_on_multiple():
	# Tester plusieurs décrements successifs
	grid.set_bomb_count(10)
	grid.right_click_on()
	grid.right_click_on()
	grid.right_click_on()
	assert_int(grid.bomb_count).is_equal(7)

# ===== TESTS INSTANTIATE_TILE =====

func test_instantiate_tile_creates_tile():
	# Vérifier qu'une tile est bien créée
	var tile = grid.instantiate_tile(0, 0)
	assert_object(tile).is_not_null()
	assert_bool(tile is Tile).is_true()


func test_instantiate_tile_sets_coords():
	# Vérifier que les coordonnées sont bien assignées
	var tile = grid.instantiate_tile(3, 5)
	assert_vector(tile.get_grid_coords()).is_equal(Vector2i(3, 5))


func test_instantiate_tile_adds_to_scene():
	# Vérifier que la tile est ajoutée comme enfant
	var initial_children = grid.get_child_count()
	var tile = grid.instantiate_tile(0, 0)
	assert_int(grid.get_child_count()).is_equal(initial_children + 1)

# ===== TESTS GENERATE_MATRICE =====

func test_generate_matrice_clears_previous():
	# Vérifier que generate_matrice nettoie la matrice précédente
	grid.generate_matrice()
	var first_tile = grid.get_tile(Vector2i(0, 0))
	
	grid.generate_matrice()
	var second_tile = grid.get_tile(Vector2i(0, 0))	
	assert_bool(first_tile != second_tile).is_true()


func test_generate_matrice_resets_bomb_count():
	# Vérifier que le compteur de bombes est réinitialisé
	grid.set_bomb_count(5)
	grid.generate_matrice()
	assert_int(grid.bomb_count).is_equal(grid.total_bombs)


func test_generate_matrice_creates_square_grid():
	# Vérifier que la grille créée est carrée
	grid.generate_matrice()
	for line in grid.matrice:
		assert_int(line.size()).is_equal(grid.columns)

# ===== TESTS LEFT_CLICK_TILE_BOMB =====

func test_left_click_tile_bomb_unveils_bombs():
	# Vérifier que toutes les bombes non marquées sont dévoilées
	grid.generate_matrice()
	grid.left_click_tile_bomb()
	
	for x in range(grid.columns):
		for y in range(grid.columns):
			var tile = grid.get_tile(Vector2i(x, y))
			if tile.value == -1 and tile.type != Tile.TYPE.FLAG:
				assert_int(tile.type).is_equal(Tile.TYPE.UNVEILED)

# ===== TESTS UNVEIL_TILES_RECURSIVE =====

func test_unveil_tiles_recursive_changes_type():
	# Vérifier que la tile est dévoilée
	grid.generate_matrice()
	var tile = grid.get_tile(Vector2i(0, 0))
	
	grid.unveil_tiles_recursive(tile)	
	assert_int(tile.type).is_equal(Tile.TYPE.UNVEILED)


func test_unveil_tiles_recursive_stops_at_numbered():
	# Vérifier que la récursion s'arrête sur une case numérotée
	grid.generate_matrice()
	
	# Trouver une tile avec une valeur > 0
	var numbered_tile = null
	for x in range(grid.columns):
		for y in range(grid.columns):
			var tile = grid.get_tile(Vector2i(x, y))
			if tile.value > 0:
				numbered_tile = tile
				break
		if numbered_tile:
			break
	
	if numbered_tile:
		grid.unveil_tiles_recursive(numbered_tile)
		assert_int(numbered_tile.type).is_equal(Tile.TYPE.UNVEILED)

# ===== TESTS D'INTÉGRATION =====

func test_full_game_generation_integrity():
	# Test d'intégrité complet de la génération
	grid.generate_matrice()
	
	var total_tiles = grid.columns * grid.columns
	var tiles_count = 0
	var bombs_count = 0
	
	for x in range(grid.columns):
		for y in range(grid.columns):
			var tile = grid.get_tile(Vector2i(x, y))
			assert_object(tile).is_not_null()
			tiles_count += 1
			
			if tile.value == -1:
				bombs_count += 1
	
	assert_int(tiles_count).is_equal(total_tiles)
	assert_int(bombs_count).is_equal(grid.total_bombs)


func test_neighbor_bomb_count_accuracy():
	# Vérifier que le comptage des bombes voisines est correct
	grid.generate_matrice()
	
	for x in range(grid.columns):
		for y in range(grid.columns):
			var tile = grid.get_tile(Vector2i(x, y))
			
			# Ne tester que les tiles qui ne sont pas des bombes
			if tile.value >= 0:
				var neighbors = grid.get_neighbor_tiles(Vector2i(x, y))
				var expected_bomb_count = 0
				
				for neighbor in neighbors:
					if neighbor.value == -1:
						expected_bomb_count += 1
				
				assert_int(tile.value).is_equal(expected_bomb_count)
