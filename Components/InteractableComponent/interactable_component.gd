class_name InteractableComponent
extends Area2D

signal interactable_activated
signal interactable_deactivated

func _on_body_entered(body: Node2D) -> void:
	interactable_activated.emit(body)

func _on_body_exited(body: Node2D) -> void:
	interactable_deactivated.emit(body)
