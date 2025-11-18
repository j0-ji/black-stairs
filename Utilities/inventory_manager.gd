extends Node

var inventory : Dictionary = Dictionary()

signal inventory_changed

func add_collectable(collectable_name : String) -> void:
	inventory.get_or_add(collectable_name, 0)
	inventory[collectable_name] += 1
	
	inventory_changed.emit()
