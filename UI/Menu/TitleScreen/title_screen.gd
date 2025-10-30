extends Control

@export var _menu_camera : Camera2D

@export var _continue_button : Button
@export var _new_game_button : Button
@export var _options_button : Button
@export var _quit_button : Button

var _main_stage = preload("res://Stages/Main/StageMain.tscn")

func _ready() -> void:
	if _menu_camera:
		_menu_camera.make_current()
	
	_continue_button.pressed.connect(_on_continue_pressed)
	_new_game_button.pressed.connect(_on_new_game_pressed)
	_options_button.pressed.connect(_on_options_pressed)
	_quit_button.pressed.connect(_on_quit_pressed)

func _on_continue_pressed() -> void:
	pass

func _on_new_game_pressed() -> void:
	_main_stage.instantiate()
	self.queue_free()

func _on_options_pressed() -> void:
	pass

func _on_quit_pressed() -> void:
	get_tree().quit()
