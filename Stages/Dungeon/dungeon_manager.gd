extends Node2D

@export var _map_generator : Node

signal generation_done

func _ready() -> void:
	_map_generator.generation_done.connect(_generation_done_repeater)

func _generation_done_repeater() -> void:
	print("DUNGEON_MANAGER.REPEATER: map generation done")
	generation_done.emit()

func initiate_generation() -> void:
	print("DUNGEON_MANAGER: map generation initiated")
	_map_generator.initiate_generation()
