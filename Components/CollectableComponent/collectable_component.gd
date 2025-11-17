class_name CollectableComponent
extends Area2D

@export var thing : Node2D

func _on_body_entered(body: Node2D) -> void:
	print("ENTERED")
	if body.is_in_group("collector"):
		thing.queue_free()
