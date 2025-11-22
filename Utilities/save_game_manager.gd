extends Node

var save_game_data_path : String = "user://game_data/"
var save_file_name : String = "save_game.tres"

var global_data : GlobalData = GlobalData.new()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("save_game"):
		save_game() 

func save_game() -> void:
	var save_level_data_component : SaveLevelDataComponent = get_tree().get_first_node_in_group("save_level_data_component")
	
	if !DirAccess.dir_exists_absolute(save_game_data_path):
		DirAccess.make_dir_absolute(save_game_data_path)
	
	if save_level_data_component != null:
		save_level_data_component.save_game()
	
	# Disable dungeon generation for next load so it does not overwrite saved data...
	if global_data.current_location == "Dungeon":
		global_data.generate_dungeon = false
		global_data.add_initial_location = false
	ResourceSaver.save(global_data, global_data.SAVE_GLOBAL_DATA_PATH)

func load_game() -> void:
	await get_tree().process_frame
	
	# first load global data
	if save_file_exists(global_data.SAVE_GLOBAL_DATA_PATH):
		global_data = ResourceLoader.load(global_data.SAVE_GLOBAL_DATA_PATH).duplicate(true)
	
	# then load the rest
	var save_level_data_component : SaveLevelDataComponent = get_tree().get_first_node_in_group("save_level_data_component")
	
	if save_level_data_component != null:
		save_level_data_component.load_game()

func save_file_exists(path : String = save_game_data_path + save_file_name) -> bool:
	return FileAccess.file_exists(path)
