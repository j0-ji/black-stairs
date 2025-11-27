extends CanvasLayer

@export var settings_screen: Control
@export var save_feedback_positive : PanelContainer
@export var save_feedback_negative : PanelContainer

func _ready() -> void:
	MusicManager.pause_music()
	MusicManager.play_menu_music(MusicManager.music_menu)

func _on_continue_pressed() -> void:
	MusicManager.stop_menu_music()
	MusicManager.resume_music()
	GameManager.continue_from_pause()

func _on_save_pressed() -> void:
	var result = GameManager.save_game()
	if result:
		_tween_feedback(save_feedback_positive)
	else:
		_tween_feedback(save_feedback_negative)

func _on_options_pressed() -> void:
	settings_screen.visible = true

func _on_quit_pressed() -> void:
	MusicManager.stop_menu_music()
	GameManager.return_to_main_menu()
	queue_free()

func _tween_feedback(feedback_control : PanelContainer) -> void:
	var tween : Tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	
	feedback_control.modulate = Color(1, 1, 1, 0)
	feedback_control.visible = true
	
	tween.tween_property(feedback_control, "modulate", Color(1, 1, 1, 1), 0.25)
	tween.tween_interval(1)
	tween.tween_property(feedback_control, "modulate", Color(1, 1, 1, 0), 0.5)
	tween.tween_callback(Callable(feedback_control, "hide"))
