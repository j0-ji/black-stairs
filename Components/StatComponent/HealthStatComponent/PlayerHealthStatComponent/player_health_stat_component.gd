class_name PlayerHealthStatComponent
extends HealthStatComponent

func _ready() -> void:
	super._ready()
	UpgradeManager.upgraded_health.connect(_on_upgrade)
	UpgradeManager.upgraded_health_regen.connect(_on_upgrade)
	apply_upgrades_after_save()

func set_max_stat_value(new_max_stat_value : int) -> void:
	super.set_max_stat_value(new_max_stat_value)

func set_current_stat_value(new_current_stat_value : int) -> void:
	super.set_current_stat_value(new_current_stat_value)

func _set_regen_time(new_regen_time) -> void:
	super._set_regen_time(new_regen_time)

func take_damage(amount: int):
	super.take_damage(amount)
	print("HP: ", current_stat_value)
	if is_dead:
		print("Player is dead")
		reset()

func _on_upgrade(upgrade : Upgrade) -> void:
	super._on_upgrade(upgrade)

func reset() -> void:
	set_current_stat_value(max_stat_value)
	is_dead = false

func apply_upgrades_after_save() -> void:
	var upgrade_health = UpgradeManager.get_upgrade("health")
	if upgrade_health != null:
		var new_max_stat_value = round(base_max_health * upgrade_health.stat_adapter)
		set_max_stat_value(new_max_stat_value)
	
	var upgrade_health_regen = UpgradeManager.get_upgrade("health_regen")
	if upgrade_health_regen != null:
		if !is_regeneratable and upgrade_health_regen.level > 0:
			is_regeneratable = true
		var new_regen_time = base_health_regen_time / upgrade_health_regen.stat_adapter
		_set_regen_time(new_regen_time)
