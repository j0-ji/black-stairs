extends Control

@export var _menu_camera : Camera2D

func _ready() -> void:
	if _menu_camera:
		_menu_camera.make_current()

func _on_continue_pressed() -> void:
	GameManager.continue_from_pause()
	queue_free()

func _on_save_pressed() -> void:
	GameManager.save_game()

func _on_options_pressed() -> void:
	pass # Replace with function body.

func _on_quit_pressed() -> void:
	GameManager.return_to_main_menu()
	queue_free()
