extends Node2D

@export var _player : Player
@export var _location_root : Node2D

var current_level : int = 0
var current_location : String = ""

func _ready() -> void:
	current_location = "Dungeon"
	SceneManager.load_location(current_location)
	await get_tree().process_frame
	current_level += 1
	_set_player_on_spawn_point()
	_set_listener_for_exit()

func _go_to_stairs() -> void:
	current_location = "Stairs"
	SceneManager.load_location(current_location)
	await get_tree().process_frame
	_set_player_on_spawn_point()
	_set_listener_for_exit()

func _go_to_next_dungeon_level() -> void:
	current_location = "Dungeon"
	SceneManager.load_location(current_location)
	await get_tree().process_frame
	current_level += 1
	_set_player_on_spawn_point()
	_set_listener_for_exit()

func _go_to_town() -> void:
	pass
	# _set_player_on_spawn_point()

func _set_player_on_spawn_point() -> void:
	var location = _location_root.get_child(0)
	if location != null:
		if location.entrance != null:
			_player.position = location.entrance.spawn_point
		else: 
			push_error("Location does not have valid entrance...")
	else: 
		push_error("No valid location in location root...")

func _set_listener_for_exit() -> void:
	var location = _location_root.get_child(0)
	if location == null:
		push_error("No valid location in location root...")
		return
	
	if location.exit == null:
		push_error("Location does not have valid exit...")
		return
	
	if location.exit.went_through_exit.is_connected(_next):
		location.exit.went_through_exit.disconnect(_next)
	
	location.exit.went_through_exit.connect(_next)

func _next() -> void:
	if current_location == "Dungeon":
		_go_to_stairs()
	elif current_location == "Stairs":
		_go_to_next_dungeon_level()
	elif current_location == "Town":
		current_level = 0
		_go_to_next_dungeon_level()
	else:
		push_error("Invalid location, or level manager missing targeted level")
