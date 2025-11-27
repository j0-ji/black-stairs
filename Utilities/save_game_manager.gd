extends Node

var global_data : GlobalData
var settings : Settings

var save_game_data_path : String = "user://game_data/"
var save_file_name : String = "save_game.tres"

func _ready() -> void:
	reset_or_initialize()
	load_settings()

func save_game() -> bool:
	if !DirAccess.dir_exists_absolute(save_game_data_path):
		DirAccess.make_dir_absolute(save_game_data_path)
	
	var save_level_data_component : SaveLevelDataComponent = get_tree().get_first_node_in_group("save_level_data_component")
	
	if save_level_data_component != null:
		save_level_data_component.save_game()

	# --- global data ---
	global_data.upgrades = UpgradeManager._upgrades
	global_data.wallet = WalletManager.wallet
	var result = ResourceSaver.save(global_data, save_game_data_path + GlobalData.SAVE_GLOBAL_DATA_FILE_NAME)
	
	return result == 0

func load_global_data() -> void: 
	if save_file_exists(GlobalData.SAVE_GLOBAL_DATA_FILE_NAME):
		global_data = ResourceLoader.load(save_game_data_path + GlobalData.SAVE_GLOBAL_DATA_FILE_NAME).duplicate(true)
	
	# global data preparation if the player was in the dungeon location
	if global_data.current_location == "Dungeon":
		if global_data.current_dungeon_level == 1:
			global_data.current_dungeon_level = 0
			global_data.current_location = "Village"
			global_data.spawn_point = global_data.spawns.ENTRANCE
		elif global_data.current_dungeon_level > 1:
			global_data.current_dungeon_level -= 1
			global_data.current_location = "Stairs"
		else:
			push_error("invalid dungeon level: ", global_data.current_dungeon_level)
	elif global_data.current_location == "Village":
		global_data.spawn_point = global_data.spawns.BED
	
	UpgradeManager._upgrades = global_data.upgrades
	WalletManager.wallet = global_data.wallet

## use after load_global_data(), and after loading the game world
func load_game() -> void:
	await get_tree().process_frame
	
	var save_level_data_component : SaveLevelDataComponent = get_tree().get_first_node_in_group("save_level_data_component")
	
	if save_level_data_component != null:
		save_level_data_component.load_game()

func save_file_exists(path : String = save_game_data_path + GlobalData.SAVE_GLOBAL_DATA_FILE_NAME) -> bool:
	return FileAccess.file_exists(path)

func delete_save_game() -> void:
	if DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(save_game_data_path)):
		var dir = DirAccess.open(save_game_data_path)
		if save_file_exists(save_game_data_path + save_file_name):
			dir.remove(save_file_name)
		if save_file_exists():
			dir.remove(GlobalData.SAVE_GLOBAL_DATA_FILE_NAME)


# --- Settings ---
func save_settings() -> void:
	if !DirAccess.dir_exists_absolute(save_game_data_path):
		DirAccess.make_dir_absolute(save_game_data_path)
	
	ResourceSaver.save(settings, save_game_data_path + Settings.SETTINGS_FILE_NAME)

func load_settings() -> void:
	if save_file_exists(save_game_data_path + settings.SETTINGS_FILE_NAME):
		settings = ResourceLoader.load(save_game_data_path + Settings.SETTINGS_FILE_NAME).duplicate(true)


# --- Utils ---
func reset_or_initialize() -> void:
	global_data = GlobalData.new()
	settings = Settings.new()
