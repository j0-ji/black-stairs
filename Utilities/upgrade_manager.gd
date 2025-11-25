extends Node

signal upgraded_health(upgrade : Upgrade)
signal upgraded_health_regen(upgrade : Upgrade)
signal upgraded_damage(upgrade : Upgrade)
signal upgraded_stamina(upgrade : Upgrade)
signal upgraded_speed(upgrade : Upgrade)

signal upgrades_changed(upgrade_name : String)

signal not_wealthy_enough

var _upgrades : Dictionary

var _upgrade_list : Array[String] = [
	"health",
	"health_regen",
	"damage",
	"stamina",
	"speed"
]

func _ready() -> void:
	reset_or_initialize()

func reset_or_initialize() -> void:
	_upgrades = Dictionary()
	_upgrades.get_or_add("health", Upgrade.new("health"))
	_upgrades.get_or_add("health_regen", Upgrade.new("health_regen"))
	_upgrades.get_or_add("damage", Upgrade.new("damage"))
	_upgrades.get_or_add("stamina", Upgrade.new("stamina", 5, 0, 1.0, 0.95, 2))
	_upgrades.get_or_add("speed", Upgrade.new("speed"))

func add_upgrade_level(upgrade_name : String) -> void:
	var upgrade = _upgrades.get(upgrade_name)
	
	var wealth = WalletManager.get_wealth()
	
	if wealth >= upgrade.price:
		# updating wealth has to happen first to get the correct price 
		# before it gets increased by adding a level
		WalletManager.update_wealth(-upgrade.price)
		upgrade.add_level()
		
		upgrades_changed.emit(upgrade_name)
		
		match upgrade_name:
			"health":
				upgraded_health.emit(upgrade)
			"health_regen":
				upgraded_health_regen.emit(upgrade)
			"damage":
				upgraded_damage.emit(upgrade)
			"stamina":
				upgraded_stamina.emit(upgrade)
			"speed":
				upgraded_speed.emit(upgrade)
			_:
				push_warning("Tried to change upgrades with invalid name: ", upgrade_name)
		
		print("added level to: ", upgrade_name)
	else:
		not_wealthy_enough.emit()

func get_upgrade_price(upgrade_name : String) -> int:
	return _upgrades.get(upgrade_name).price

func get_upgrade_level(upgrade_name : String) -> int:
	return _upgrades.get(upgrade_name).level

func get_upgrade_stat_adapter(upgrade_name : String) -> float:
	return _upgrades.get(upgrade_name).stat_adapter

func has_upgrade(upgrade_name : String) -> bool:
	return _upgrades.has(upgrade_name)

func set_upgrades(upgrades : Array[Upgrade]) -> void:
	for upgrade in upgrades:
		if upgrade.name in _upgrade_list:
			_upgrades[upgrade.name] = upgrade
