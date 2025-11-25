class_name PlayerHealthStatComponent
extends HealthStatComponent

func _ready() -> void:
	super._ready()
	UpgradeManager.upgraded_health.connect(_on_upgrade)

func set_max_stat_value(new_max_stat_value : int) -> void:
	super.set_max_stat_value(new_max_stat_value)

func set_current_stat_value(new_current_stat_value : int) -> void:
	super.set_current_stat_value(new_current_stat_value)

func _set_regen_time(new_regen_time) -> void:
	super._set_regen_time(new_regen_time)

func take_damage(amount: int):
	super.take_damage(amount)
	if is_dead:
		reset()

func _on_upgrade(upgrade : Upgrade) -> void:
	super._on_upgrade(upgrade)
	
func register_parent_entity(entity : CharacterBody2D) -> void:
	super.register_parent_entity(entity)

func reset() -> void:
	set_current_stat_value(max_stat_value)
	is_dead = false
