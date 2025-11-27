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
	if body.is_in_group("collector") and body.is_in_group("player"):
		if collectable_name.contains("coin"):
			WalletManager.add_coin()
		if collectable_name.contains("scroll_of_knowledge"):
			EventBus.play_transition.emit(
				"Short Introduction", 
				"Scroll of Knowledge", 
				"The trader gave you a dagger (left mouse button) and a bow (right mouse button). You also have the ability to dash (shift). Using your dash ability and your bow consumes stamina (yellow bar; top left). Time to explore the dungeon Adventurer!")
			SaveGameManager.global_data.collected_scroll_of_knowledge = true
		
		get_parent().queue_free()
