extends Node

signal upgrades_changed
signal not_wealthy_enough

var _upgrades : Dictionary = Dictionary()

var _upgrade_list : Array[String] = [
	"base_health",
	"health_regen",
	"damage",
	"stamina",
	"speed"
]

func _ready() -> void:
	for upgrade in _upgrade_list:
		_upgrades.get_or_add(upgrade, Upgrade.new())

func add_upgrade_level(upgrade_name : String) -> void:
	var upgrade = _upgrades.get(upgrade_name)
	var wealth = WalletManager.get_wealth()
	
	if  wealth >= upgrade.price:
		# updating wealth has to happen first to get the correct price 
		# before it gets increased by adding a level
		WalletManager.update_wealth(-upgrade.price)
		upgrade.add_level()
		upgrades_changed.emit()
	else:
		not_wealthy_enough.emit()

func get_upgrade_price(upgrade_name : String) -> int:
	return _upgrades.get(upgrade_name).price

func get_upgrade_level(upgrade_name : String) -> int:
	return _upgrades.get(upgrade_name).level

func get_upgrade_multiplicator(upgrade_name : String) -> float:
	return _upgrades.get(upgrade_name).multiplicator

func has_upgrade(upgrade_name : String) -> bool:
	return _upgrades.has(upgrade_name)
