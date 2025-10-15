extends Area2D

signal went_through_exit

@export var _hint : ColorRect
var _player_inside := false

func _ready() -> void:
	_hint.visible = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body : Node) -> void:
	if body.is_in_group("player"):
		_player_inside = true
		_hint.visible = true

func _on_body_exited(body : Node) -> void:
	if body.is_in_group("player"):
		_player_inside = false
		_hint.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if _player_inside and event.is_action_pressed("interaction"):
		went_through_exit.emit()
