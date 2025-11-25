class_name PlayerSpeedStatComponent
extends SpeedStatComponent

func _ready() -> void:
	super._ready()
	UpgradeManager.upgraded_speed.connect(_on_upgrade)

func set_max_stat_value(new_max_stat_value : int) -> void:
	super.set_max_stat_value(new_max_stat_value)

func set_current_stat_value(new_current_stat_value : int) -> void:
	super.set_current_stat_value(new_current_stat_value)

func _on_upgrade(upgrade : Upgrade) -> void:
	super._on_upgrade(upgrade)
