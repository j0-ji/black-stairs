extends Node2D

signal went_through_exit

@export var hint : PanelContainer
var _player_inside := false

func _ready() -> void:
	hint.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if _player_inside and event.is_action_pressed("interaction"):
		went_through_exit.emit()

func _on_interactable_activated(body) -> void:
	if body.is_in_group("player"):
		_player_inside = true
		hint.visible = true

func _on_interactable_deactivated(body) -> void:
	if body.is_in_group("player"):
		_player_inside = false
		hint.visible = false
