extends Node

var upgrades : Dictionary = Dictionary()

signal upgrades_changed

func add_upgrade(upgrade_name : String) -> void:
	upgrades.get_or_add(upgrade_name, 0)
	upgrades[upgrade_name] += 1
	
	upgrades_changed.emit()
