class_name CollectableComponent
extends Area2D

## Enables an object to be collected by a collector
##
## Objects that use this component can be collected by other objects that fit the collision layer
## mask AND are in the collector group.
## Adding further collision masks extends by whom the object can be collected.
## 
## For proper use, add a collision shape as a child node to the collectable component. 

@export var collectable_name : String

# currently just deletes the object
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("collector"):
		InventoryManager.add_collectable(collectable_name)
		get_parent().queue_free()
						  
