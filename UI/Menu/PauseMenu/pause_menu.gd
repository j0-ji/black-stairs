extends CanvasLayer

@export var settings_screen: Control

func _ready() -> void:
	MusicManager.pause_music()
	MusicManager.play_menu_music(MusicManager.music_menu)

func _on_continue_pressed() -> void:
	MusicManager.stop_menu_music()
	MusicManager.resume_music()
	GameManager.continue_from_pause()

func _on_save_pressed() -> void:
	GameManager.save_game()

func _on_options_pressed() -> void:
	settings_screen.visible = true

func _on_quit_pressed() -> void:
	MusicManager.stop_menu_music()
	GameManager.return_to_main_menu()
	queue_free()
