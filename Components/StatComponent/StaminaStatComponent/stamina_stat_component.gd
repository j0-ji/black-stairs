class_name StaminaStatComponent
extends StatComponent

signal stamina_updated(new_stamina : int)
signal max_stamina_updated(new_max_stamina : int)

@export var base_max_stamina : int
@export var base_stamina_regen_time : float = 5.0

func _ready():
	super._ready()
	is_regeneratable = true
	set_max_stat_value(base_max_stamina)
	_set_regen_time(base_stamina_regen_time)

func set_max_stat_value(new_max_stat_value : int) -> void:
	super.set_max_stat_value(new_max_stat_value)
	max_stamina_updated.emit(max_stat_value)
	set_current_stat_value(max_stat_value)

func set_current_stat_value(new_current_stat_value : int) -> void:
	super.set_current_stat_value(new_current_stat_value)
	stamina_updated.emit(current_stat_value)

func _set_regen_time(new_regen_time) -> void:
	super._set_regen_time(new_regen_time)

func _on_upgrade(upgrade : Upgrade) -> void:
	super._on_upgrade(upgrade)
	
	var new_max_stat_value = base_max_stamina + upgrade.level
	set_max_stat_value(new_max_stat_value)
	
	var new_regen_time = base_stamina_regen_time / upgrade.stat_adapter
	_set_regen_time(new_regen_time)

func register_parent_entity(entity : CharacterBody2D) -> void:
	super.register_parent_entity(entity)

func use_stamina(amount : int) -> bool:
	if amount < current_stat_value:
		var new_current_stat_value = current_stat_value - amount
		set_current_stat_value(new_current_stat_value)
		return true
	else:
		return false
