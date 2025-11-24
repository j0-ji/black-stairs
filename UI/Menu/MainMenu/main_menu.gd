extends Control

@export var continue_button : Button

@export var credits_screen : Control

@export var _menu_camera : Camera2D

func _ready() -> void:
	if _menu_camera:
		_menu_camera.make_current()
	
	if !SaveGameManager.save_file_exists():
		continue_button.disabled = true
		continue_button.focus_mode = Control.FOCUS_NONE

func _on_new_game_pressed() -> void:
	GameManager.new_game()
	queue_free()
	
func _on_continue_pressed() -> void:
	GameManager.continue_game()
	queue_free()

func _on_credits_pressed() -> void:
	credits_screen.visible = true

func _on_quit_pressed() -> void:
	GameManager.exit_game()
