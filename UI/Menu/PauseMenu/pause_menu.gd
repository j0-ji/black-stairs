extends CanvasLayer

func _on_continue_pressed() -> void:
	GameManager.continue_from_pause()

func _on_save_pressed() -> void:
	GameManager.save_game()

func _on_options_pressed() -> void:
	pass # Replace with function body.

func _on_quit_pressed() -> void:
	GameManager.return_to_main_menu()
	queue_free()
