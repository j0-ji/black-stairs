class_name PlayerStaminaStatComponent
extends StaminaStatComponent

func _ready() -> void:
	super._ready()
	UpgradeManager.upgraded_stamina.connect(_on_upgrade)
	apply_upgrades_after_save()

func set_max_stat_value(new_max_stat_value : int) -> void:
	super.set_max_stat_value(new_max_stat_value)

func set_current_stat_value(new_current_stat_value : int) -> void:
	super.set_current_stat_value(new_current_stat_value)

func _set_regen_time(new_regen_time) -> void:
	super._set_regen_time(new_regen_time)

func _on_upgrade(upgrade : Upgrade) -> void:
	super._on_upgrade(upgrade)

func use_stamina(amount : int) -> bool:
	return super.use_stamina(amount)

func reset() -> void:
	set_current_stat_value(max_stat_value)

func apply_upgrades_after_save() -> void:
	var upgrade = UpgradeManager.get_upgrade("stamina")
	if upgrade != null:
		var new_max_stat_value = base_max_stamina + upgrade.level
		set_max_stat_value(new_max_stat_value)
	
		var new_regen_time = base_stamina_regen_time / upgrade.stat_adapter
		_set_regen_time(new_regen_time)
