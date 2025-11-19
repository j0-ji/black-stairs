extends PanelContainer

@onready var coin_label: Label = $MarginContainer/HBoxContainer/Coins/CoinLabel
@onready var base_health_upgrade_label: Label = $MarginContainer/HBoxContainer/BaseHealthUpgrades/BaseHealthUpgradeLabel
@onready var health_regen_upgrade_label: Label = $MarginContainer/HBoxContainer/HealthRegenUpgrades/HealthRegenUpgradeLabel
@onready var damage_upgrade_label: Label = $MarginContainer/HBoxContainer/DamageUpgrades/DamageUpgradeLabel
@onready var speed_upgrade_label: Label = $MarginContainer/HBoxContainer/SpeedUpgrades/SpeedUpgradeLabel
@onready var stamina_upgrade_label: Label = $MarginContainer/HBoxContainer/StaminaUpgrades/StaminaUpgradeLabel

func _ready() -> void:
	# InventoryManager.inventory_changed.connect(_on_inventory_changed)
	WalletManager.wallet_changed.connect(_update_wallet)
	UpgradeManager.upgrades_changed.connect(_update_upgrades)
	_update_wallet()
	_update_upgrades()

func _update_wallet() -> void:
	var wealth : int = WalletManager.get_wealth()
	coin_label.text = str(wealth)

func _update_upgrades() -> void:
	if UpgradeManager.has_upgrade("base_health"):
		base_health_upgrade_label.text = str(UpgradeManager.get_upgrade_count("base_health"))
	
	if UpgradeManager.has_upgrade("health_regen"):
		health_regen_upgrade_label.text = str(UpgradeManager.get_upgrade_count("health_regen"))
	
	if UpgradeManager.has_upgrade("damage"):
		damage_upgrade_label.text = str(UpgradeManager.get_upgrade_count("damage"))
	
	if UpgradeManager.has_upgrade("speed"):
		speed_upgrade_label.text = str(UpgradeManager.get_upgrade_count("speed"))
	
	if UpgradeManager.has_upgrade("stamina"):
		stamina_upgrade_label.text = str(UpgradeManager.get_upgrade_count("stamina"))
