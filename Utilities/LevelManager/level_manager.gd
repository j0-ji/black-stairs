extends Node

@export var _dungeon : Node2D
@export var _stairs : Node2D
@export var _player : Player

var _current_level : int = 1
var _is_in_dungeon : bool = true

func _ready() -> void:
	_dungeon.map_generator.generation_done.connect(_post_first_generation, CONNECT_ONE_SHOT)
	_dungeon.exit.went_through_exit.connect(_next_step)
	_stairs.exit.went_through_exit.connect(_next_step)
	
	print("LEVEL_MANAGER: map generation initiated")
	_dungeon.generate()

func _post_first_generation() -> void:
	print("LEVEL_MANAGER: map generation done")
	
	_dungeon.entrance.update_spawn_point()
	_player.position = _dungeon.entrance.spawn_point
	print("LEVEL_MANAGER: ", _current_level)

func _next_step() -> void:
	if _is_in_dungeon:
		# switch to stairs
		_stairs.entrance.update_spawn_point()
		_player.position = _stairs.entrance.spawn_point
		_is_in_dungeon = false
		_dungeon.generate()
	else:
		# switch to dungeon
		_current_level += 1
		_dungeon.entrance.update_spawn_point()
		_player.position = _dungeon.entrance.spawn_point
		_is_in_dungeon = true
		print("LEVEL_MANAGER: level ", _current_level)
