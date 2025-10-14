extends Node

@export var _dungeon : Node2D
@export var _stairs : Node2D
@export var _player : Player

func _ready() -> void:
	_dungeon.generation_done.connect(placeholder)
	
	print("LEVEL_MANAGER: map generation initiated")
	_dungeon.initiate_generation()

func placeholder() -> void:
	print("LEVEL_MANAGER: map generation done")
	
	_dungeon.entrance.update_spawn_point()
	_player.position = _dungeon.entrance.spawn_point
