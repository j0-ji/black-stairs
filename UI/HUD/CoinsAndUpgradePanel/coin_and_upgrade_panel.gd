extends PanelContainer

@onready var coin_label: Label = $MarginContainer/HBoxContainer/Coins/CoinLabel
@onready var health_upgrade_label: Label = $MarginContainer/HBoxContainer/HealthUpgrades/HealthUpgradeLabel
@onready var health_regen_upgrade_label: Label = $MarginContainer/HBoxContainer/HealthRegenUpgrades/HealthRegenUpgradeLabel
@onready var damage_upgrade_label: Label = $MarginContainer/HBoxContainer/DamageUpgrades/DamageUpgradeLabel
@onready var speed_upgrade_label: Label = $MarginContainer/HBoxContainer/SpeedUpgrades/SpeedUpgradeLabel
@onready var stamina_upgrade_label: Label = $MarginContainer/HBoxContainer/StaminaUpgrades/StaminaUpgradeLabel

func _ready() -> void:
	WalletManager.wallet_changed.connect(_update_wallet)
	UpgradeManager.upgrades_changed.connect(_update_upgrades)
	_update_wallet()
	_update_upgrades("placeholder")

func _update_wallet() -> void:
	var wealth : int = WalletManager.get_wealth()
	coin_label.text = str(wealth)

func _update_upgrades(_foo : String) -> void:
	print("RUN: _update_upgrades")
	if UpgradeManager.has_upgrade("health"):
		health_upgrade_label.text = str(UpgradeManager.get_upgrade_level("health"))
	
	if UpgradeManager.has_upgrade("health_regen"):
		health_regen_upgrade_label.text = str(UpgradeManager.get_upgrade_level("health_regen"))
	
	if UpgradeManager.has_upgrade("damage"):
		damage_upgrade_label.text = str(UpgradeManager.get_upgrade_level("damage"))
	
	if UpgradeManager.has_upgrade("speed"):
		speed_upgrade_label.text = str(UpgradeManager.get_upgrade_level("speed"))
	
	if UpgradeManager.has_upgrade("stamina"):
		stamina_upgrade_label.text = str(UpgradeManager.get_upgrade_level("stamina"))
