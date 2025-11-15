extends Node2D

signal went_through

@export var spawn_marker : Marker2D
@export var hint : ColorRect
@export var exit_enabled : bool = false

var spawn_point := Vector2i(0, 0)
var _player_inside = false

func _ready() -> void:
	update_spawn_point()
	hint.visible = false
	
func _unhandled_input(event: InputEvent) -> void:
	if _player_inside and event.is_action_pressed("interaction"):
		went_through.emit()

## has to be called before spawning player if entrace was rotated or moved after initialization
func update_spawn_point() -> void:
	spawn_point = spawn_marker.global_position as Vector2i
	hint.rotation_degrees = -rotation_degrees

func _on_interactable_activated(body : Node2D) -> void:
	if exit_enabled and body.is_in_group("player"):
		_player_inside = true
		hint.visible = true

func _on_interactable_deactivated(body : Node2D) -> void:
	if exit_enabled and body.is_in_group("player"):
		_player_inside = false
		hint.visible = false
