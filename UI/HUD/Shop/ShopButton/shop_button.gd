extends Button

@export var upgrade_name : String

func _ready() -> void:
	UpgradeManager.upgrades_changed.connect(_update_price)
	_update_price("placeholder")

func _on_pressed() -> void:
	UpgradeManager.add_upgrade_level(upgrade_name)
	_update_price("placeholder")

func _update_price(_foo : String) -> void:
	var price : int = UpgradeManager.get_upgrade_price(upgrade_name)
	text = str(price)
