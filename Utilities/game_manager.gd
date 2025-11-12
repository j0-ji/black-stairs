extends Node

signal focus_player_camera

var menu_main = preload("res://UI/Menu/MainMenu/main_menu.tscn")
var menu_pause = preload("res://UI/Menu/PauseMenu/pause_menu.tscn")
var stage_main_root_path : String = "/root/StageMain"
var menu_main_root_path : String = "/root/MainMenu"
var menu_pause_root_path : String = "/root/PauseMenu"


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_pause_menu"):
		_toggle_menu_pause()

func new_game() -> void:
	SceneManager.load_main_stage_container()

func continue_game() -> void:
	# TODO: load game from save file and run
	pass

func continue_from_pause() -> void:
	_toggle_menu_pause()

func save_game() -> void:
	# TODO: save the game 
	pass

func return_to_main_menu() -> void:
	# TODO: save the game
	# currently just delete current game scene
	if get_tree().root.has_node(stage_main_root_path):
		var stage_main = get_tree().root.get_node(stage_main_root_path)
		stage_main.queue_free()
	
	# TODO: switch to main menu
	var menu_main_instance = menu_main.instantiate()
	get_tree().root.add_child(menu_main_instance)
	
	if get_tree().root.has_node(menu_pause_root_path):
		var menu_pause_node = get_tree().root.get_node(menu_pause_root_path)
		menu_pause_node.queue_free()

func exit_game() -> void:
	get_tree().quit()

func _toggle_menu_pause() -> void:
	if get_tree().root.has_node(stage_main_root_path):
		var stage_main = get_tree().root.get_node(stage_main_root_path)
		if stage_main.process_mode == Node.PROCESS_MODE_INHERIT:
			var menu_pause_instance = menu_pause.instantiate()
			get_tree().root.add_child(menu_pause_instance)
			stage_main.process_mode = Node.PROCESS_MODE_DISABLED
		elif stage_main.process_mode == Node.PROCESS_MODE_DISABLED:
			var menu_pause_node = get_tree().root.get_node(menu_pause_root_path)
			menu_pause_node.queue_free()
			focus_player_camera.emit()
			stage_main.process_mode = Node.PROCESS_MODE_INHERIT
		else: push_error("Invalid main stage process mode...")
