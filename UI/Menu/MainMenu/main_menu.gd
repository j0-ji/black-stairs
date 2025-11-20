extends Control

@export var _menu_camera : Camera2D

func _ready() -> void:
	if _menu_camera:
		_menu_camera.make_current()

func _on_new_game_pressed() -> void:
	GameManager.new_game()
	queue_free()
	
func _on_continue_pressed() -> void:
	GameManager.continue_game()
	queue_free()

func _on_options_pressed() -> void:
	pass # Replace with function body.

func _on_quit_pressed() -> void:
	GameManager.exit_game()
