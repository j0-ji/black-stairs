extends Node2D

@export_multiline var message : String
@export var hint_component : HintComponent

var _is_active : bool

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action("interaction") and _is_active:
		EventBus.player_message.emit(message)


func _on_interactable_activated(body : Node2D) -> void:
	if body.is_in_group("player"):
		_is_active = true
	
	hint_component.visible = true


func _on_interactable_deactivated(body : Node2D) -> void:
	if body.is_in_group("player"):
		_is_active = false
	
	hint_component.visible = false
