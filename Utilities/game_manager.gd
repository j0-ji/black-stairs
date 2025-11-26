extends Node

# GameManager (global autoload)
# 
# This script manages the core game and menu states for the project.
# It is responsible for transitioning between the main game, pause menu, and main menu,
# handling input for menu toggling, and coordinating scene changes.
# 
# GameManager interacts with SceneManager to load the main game stage and handles
# the creation and destruction of menu scenes (main menu and pause menu) by instantiating
# and freeing their nodes as needed.
# 
# Menu lifecycle:
# - Main menu is instantiated when returning to the main menu or at startup.
# - Pause menu is instantiated when toggled during gameplay and destroyed when resuming.
# - Game stage is loaded via SceneManager and freed when returning to the main menu.
# 
# This script should be used for high-level game state transitions and menu management

signal focus_player_camera

var menu_main = preload("res://UI/Menu/MainMenu/main_menu.tscn")
var menu_pause = preload("res://UI/Menu/PauseMenu/pause_menu.tscn")
var stage_main_root_path : String = "/root/Main"
var menu_main_root_path : String = "/root/MainMenu"
var menu_pause_root_path : String = "/root/PauseMenu"

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_pause_menu"):
		_toggle_menu_pause()

func new_game() -> void:
	SaveGameManager.delete_save_game()
	SaveGameManager.reset_or_initialize()
	UpgradeManager.reset_or_initialize()
	WalletManager.reset_or_initialize()
	SceneManager.load_main_stage_container()
	await get_tree().process_frame
	SaveGameManager.save_game()

func continue_game() -> void:
	SaveGameManager.load_global_data()
	SceneManager.load_main_stage_container()
	SaveGameManager.load_game()

func continue_from_pause() -> void:
	_toggle_menu_pause()

func save_game() -> void:
	SaveGameManager.save_game()

func return_to_main_menu() -> void:
	SaveGameManager.save_game()
	_toggle_menu_pause()
	
	if get_tree().root.has_node(stage_main_root_path):
		var stage_main = get_tree().root.get_node(stage_main_root_path)
		stage_main.queue_free()
	
	# TODO: switch to main menu
	var menu_main_instance = menu_main.instantiate()
	get_tree().root.add_child(menu_main_instance)

func exit_game() -> void:
	get_tree().quit()

func _toggle_menu_pause() -> void:
	if get_tree().paused:
		# Unpause
		get_tree().paused = false
		MusicManager.stop_menu_music()
		MusicManager.resume_music()
		if get_tree().root.has_node(menu_pause_root_path):
			var menu_pause_node = get_tree().root.get_node(menu_pause_root_path)
			menu_pause_node.queue_free()
		
		focus_player_camera.emit()
	else:
		# Pause
		get_tree().paused = true
		MusicManager.pause_music()
		MusicManager.play_menu_music(MusicManager.music_menu)
		var menu_pause_instance = menu_pause.instantiate()
		get_tree().root.add_child(menu_pause_instance)

func game_pause() -> void:
	get_tree().paused = true

func game_unpause() -> void:
	get_tree().paused = false
