class_name PlayerStaminaStatComponent
extends StaminaStatComponent

func _ready() -> void:
	super._ready()
	UpgradeManager.upgraded_stamina.connect(_on_upgrade)

func set_max_stat_value(new_max_stat_value : int) -> void:
	super.set_max_stat_value(new_max_stat_value)

func set_current_stat_value(new_current_stat_value : int) -> void:
	super.set_current_stat_value(new_current_stat_value)

func _set_regen_time(new_regen_time) -> void:
	super._set_regen_time(new_regen_time)

func _on_upgrade(upgrade : Upgrade) -> void:
	super._on_upgrade(upgrade)

func register_parent_entity(entity : CharacterBody2D) -> void:
	super.register_parent_entity(entity)

func use_stamina(amount : int) -> bool:
	return super.use_stamina(amount)

func reset() -> void:
	set_current_stat_value(max_stat_value)
