extends Button

@export var upgrade_name : String

func _ready() -> void:
	UpgradeManager.upgrades_changed.connect(_update_price)
	_update_price()

func _on_pressed() -> void:
	UpgradeManager.add_upgrade_level(upgrade_name)

func _update_price() -> void:
	var price : int = UpgradeManager.get_upgrade_price(upgrade_name)
	text = str(price)
