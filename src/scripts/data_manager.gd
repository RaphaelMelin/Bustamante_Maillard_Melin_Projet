class_name DataManager

## -------------------------------- DataManager --------------------------------


static func save_data(data: Dictionary, path: String) -> void:
	var file : FileAccess = FileAccess.open(path, FileAccess.WRITE)
	file.store_var(data)
	file.close()


static func load_data(path: String) -> Dictionary:
	if FileAccess.file_exists(path):
		var file : FileAccess = FileAccess.open(path, FileAccess.READ)
		var data : Dictionary = file.get_var()
		file.close()
		return data
	else:
		print("Aucun fichier trouvé à :", path)
		return {}
