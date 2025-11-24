extends Node2D

signal went_through_exit

@export var hint : PanelContainer
@export var sprite : Sprite2D
var _player_inside : bool = false
var is_locked : bool = false

var texture_unlocked : Texture = load("res://Entities/Map/Exit/exit.png")
var texture_locked : Texture = load("res://Entities/Map/Exit/exit_locked.png")

func _ready() -> void:
	hint.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if _player_inside and event.is_action_pressed("interaction"):
		if !is_locked:
			went_through_exit.emit()
		else:
			EventBus.player_message.emit("Defeat the Boss(es) first.")

func _on_interactable_activated(body) -> void:
	if body.is_in_group("player"):
		_player_inside = true
		if !is_locked:
			hint.visible = true

func _on_interactable_deactivated(body) -> void:
	if body.is_in_group("player"):
		_player_inside = false
		hint.visible = false

func lock() -> void:
	sprite.texture = texture_locked
	is_locked = true

func unlock() -> void:
	sprite.texture = texture_unlocked
	is_locked = false
