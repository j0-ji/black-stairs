class_name PlayerSpeedStatComponent
extends SpeedStatComponent

func _ready() -> void:
	super._ready()
	UpgradeManager.upgraded_speed.connect(_on_upgrade)
	apply_upgrades_after_save()

func set_max_stat_value(new_max_stat_value : int) -> void:
	super.set_max_stat_value(new_max_stat_value)

func set_current_stat_value(new_current_stat_value : int) -> void:
	super.set_current_stat_value(new_current_stat_value)

func _on_upgrade(upgrade : Upgrade) -> void:
	super._on_upgrade(upgrade)

func apply_upgrades_after_save() -> void:
	var upgrade = UpgradeManager.get_upgrade("speed")
	if upgrade != null:
		var new_max_stat_value = round(base_max_speed * upgrade.stat_adapter)
		set_max_stat_value(new_max_stat_value)
