class_name SpeedStatComponent
extends StatComponent

@export var base_max_speed : int

func _ready():
	super._ready()
	set_max_stat_value(base_max_speed)

func set_max_stat_value(new_max_stat_value : int) -> void:
	super.set_max_stat_value(new_max_stat_value)
	set_current_stat_value(max_stat_value)

func set_current_stat_value(new_current_stat_value : int) -> void:
	super.set_current_stat_value(new_current_stat_value)

func _on_upgrade(upgrade : Upgrade) -> void:
	super._on_upgrade(upgrade)
	
	var new_max_stat_value = round(base_max_speed * upgrade.stat_adapter)
	set_max_stat_value(new_max_stat_value)

func register_parent_entity(entity : CharacterBody2D) -> void:
	super.register_parent_entity(entity)
