extends PanelContainer

@onready var coin_label: Label = $MarginContainer/HBoxContainer/Coins/CoinLabel
@onready var base_health_upgrade_label: Label = $MarginContainer/HBoxContainer/BaseHealthUpgrades/BaseHealthUpgradeLabel
@onready var health_regen_upgrade_label: Label = $MarginContainer/HBoxContainer/HealthRegenUpgrades/HealthRegenUpgradeLabel
@onready var damage_upgrade_label: Label = $MarginContainer/HBoxContainer/DamageUpgrades/DamageUpgradeLabel
@onready var speed_upgrade_label: Label = $MarginContainer/HBoxContainer/SpeedUpgrades/SpeedUpgradeLabel
@onready var stamina_upgrade_label: Label = $MarginContainer/HBoxContainer/StaminaUpgrades/StaminaUpgradeLabel

func _ready() -> void:
	InventoryManager.inventory_changed.connect(_on_inventory_changed)
	UpgradeManager.upgrades_changed.connect(_on_upgrades_changed)

func _on_inventory_changed() -> void:
	var inventory : Dictionary = InventoryManager.inventory
	
	if inventory.has("coin"):
		coin_label.text = str(inventory["coin"])

func _on_upgrades_changed() -> void:
	var upgrades : Dictionary = UpgradeManager.upgrades
	
	if upgrades.has("base_health"):
		base_health_upgrade_label.text = str(upgrades["base_health"])
	
	if upgrades.has("health_regen"):
		health_regen_upgrade_label.text = str(upgrades["health_regen"])
	
	if upgrades.has("damage"):
		damage_upgrade_label.text = str(upgrades["damage"])
	
	if upgrades.has("speed"):
		speed_upgrade_label.text = str(upgrades["speed"])
	
	if upgrades.has("stamina"):
		stamina_upgrade_label.text = str(upgrades["stamina"])
