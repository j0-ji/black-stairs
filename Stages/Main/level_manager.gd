extends Node2D

@export var _player : Player
@export var _location_root : Node2D

func _ready() -> void:
	_current()

func _go_to_stairs() -> void:
	SaveGameManager.global_data.current_location = "Stairs"
	SceneManager.load_location(SaveGameManager.global_data.current_location)
	await get_tree().process_frame
	_set_listener_for_entrance()
	_set_listener_for_exit()
	_set_player_on_entrance_spawn_point()

func _go_to_next_dungeon_level() -> void:
	SaveGameManager.save_game()
	SaveGameManager.global_data.current_location = "Dungeon"
	SceneManager.load_location(SaveGameManager.global_data.current_location)
	await get_tree().process_frame
	SaveGameManager.global_data.current_dungeon_level += 1
	_set_player_on_entrance_spawn_point()
	_set_listener_for_exit()
	SaveGameManager.save_game()

func _go_to_village() -> void:
	SaveGameManager.global_data.current_location = "Village"
	SceneManager.load_location(SaveGameManager.global_data.current_location)
	await get_tree().process_frame
	if SaveGameManager.global_data.spawn_point == SaveGameManager.global_data.spawns.BED:
		_set_player_on_bed_spawn_point()
	else:
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
	if SaveGameManager.global_data.current_location == "Dungeon":
		_go_to_stairs()
	elif SaveGameManager.global_data.current_location == "Stairs":
		_go_to_next_dungeon_level()
	elif SaveGameManager.global_data.current_location == "Village":
		SaveGameManager.global_data.current_dungeon_level = 0
		_go_to_next_dungeon_level()
	else:
		push_error("Invalid location, or level manager missing targeted level")

## used to load initial location. The game saves either the Village or Stairs locations
## but not the Dungeon location. This way the player is either reset to the village if he 
## was in level 1 of the dungeon or is reset to the last stairs location he was in before 
## going into the next dungeon level
func _current() -> void:
	if SaveGameManager.global_data.current_location == "Stairs":
		_go_to_stairs()
	elif SaveGameManager.global_data.current_location == "Village":
		SaveGameManager.global_data.current_dungeon_level = 0
		_go_to_village()
	else:
		push_error("Invalid location, or level manager missing targeted level")


func _get_valid_location(i : int = 0) -> Node2D:
	var location = _location_root.get_child(i)
	
	if location == null:
		push_error("No valid location in location root...")
		return null
	
	if location.name != SaveGameManager.global_data.current_location:
		return _get_valid_location(i+1)
	
	return location
