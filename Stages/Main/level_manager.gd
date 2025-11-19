extends Node2D

@export var _player : Player
@export var _location_root : Node2D

var current_level : int = 0
var current_location : String = ""

func _ready() -> void:
	current_location = "Village"
	SceneManager.load_location(current_location)
	await get_tree().process_frame
	_set_player_on_bed_spawn_point()
	_set_listener_for_exit()

func _go_to_stairs() -> void:
	current_location = "Stairs"
	SceneManager.load_location(current_location)
	await get_tree().process_frame
	_set_listener_for_entrance()
	_set_listener_for_exit()
	_set_player_on_entrance_spawn_point()

func _go_to_next_dungeon_level() -> void:
	current_location = "Dungeon"
	SceneManager.load_location(current_location)
	await get_tree().process_frame
	current_level += 1
	_set_player_on_entrance_spawn_point()
	_set_listener_for_exit()

func _go_to_village() -> void:
	current_location = "Village"
	SceneManager.load_location(current_location)
	await get_tree().process_frame
	_set_player_on_entrance_spawn_point()
	_set_listener_for_exit()

func _set_player_on_entrance_spawn_point() -> void:
	var location = _get_valid_location()
	
	if location.entrance == null:
		push_error("Location does not have valid entrance...")
		return
	
	_player.position = location.entrance.spawn_point

func _set_player_on_bed_spawn_point() -> void:
	var location = _get_valid_location()
	
	if location.bed == null:
		push_error("Location does not have valid bed...")
		return
	
	_player.position = location.bed.spawn_point

func _set_listener_for_exit() -> void:
	var location = _get_valid_location()
	
	if location.exit == null:
		push_error("Location does not have valid exit...")
		return
	
	location.exit.went_through_exit.connect(_next, CONNECT_ONE_SHOT)

func _set_listener_for_entrance() -> void:
	var location = _get_valid_location()
	if location.entrance == null:
		push_error("Location does not have valid entrance...")
		return
	
	if !location.entrance.exit_enabled:
		push_error("Entrance of location can not be used as exit...")
		return
	
	location.entrance.went_through.connect(_go_to_village, CONNECT_ONE_SHOT)

func _next() -> void:
	if current_location == "Dungeon":
		_go_to_stairs()
	elif current_location == "Stairs":
		_go_to_next_dungeon_level()
	elif current_location == "Village":
		current_level = 0
		_go_to_next_dungeon_level()
	else:
		push_error("Invalid location, or level manager missing targeted level")

func _get_valid_location(i : int = 0) -> Node2D:
	var location = _location_root.get_child(i)
	
	if location == null:
		push_error("No valid location in location root...")
		return null
	
	if location.name != current_location:
		return _get_valid_location(i+1)
	
	return location
