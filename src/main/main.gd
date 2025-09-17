extends Control

var timer
@onready var grid: GridContainer = $VBoxContainer/Grid


func _ready() -> void:
	print("Hello world")


func _on_reset_btn_button_up() -> void:
	grid.generate_matrice()

	 # Replace with function body.
