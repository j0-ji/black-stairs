extends Node2D

signal generate_level_ground
signal generate_level_flora
signal generate_level_io

@onready var _ground : TileMapLayer = get_node("Ground") as TileMapLayer
@onready var _flora : TileMapLayer = get_node("Flora") as TileMapLayer
@onready var _io : Node2D = get_node("IO") as Node2D

func _ready() -> void:
	initialize_generation()

# REMOVE ON FOR RELEASE BUILD OR SOMEHOW EXTRACT TO ONLY BE ACCESSIBLE TO STAGING SCENES
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		initialize_generation()

func initialize_generation() -> void:
	await _ground.ready
	generate_level_ground.emit()
	print("#level_map_manager: ground generation initialized")

func on_ground_generation_done() -> void:
	await _flora.ready
	generate_level_flora.emit()
	print("#level_map_manager: flora generation initialized")

func on_flora_generation_done() -> void:
	await _io.ready
	generate_level_io.emit()
	print("#level_map_manager: io generation initialized")
