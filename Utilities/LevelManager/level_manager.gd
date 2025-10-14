extends Node

@export var _dungeon : Node2D
@export var _stairs : Node2D
@export var _player : Player

func _ready() -> void:
	_dungeon.generation_done.connect(placeholder)
	
	print("MAIN: map generation initiated")
	_dungeon.initiate_generation()

func placeholder() -> void:
	print("MAIN: map generation done")
