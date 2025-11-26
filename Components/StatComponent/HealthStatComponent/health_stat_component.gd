class_name HealthStatComponent
extends StatComponent

signal died()
signal health_updated(new_health : int)
signal max_health_updated(new_max_health : int)

@export var base_max_health : int
@export var base_health_regen_time : float = 1.0

var is_dead : bool = false

func _ready():
	super._ready()
	set_max_stat_value(base_max_health)
	_set_regen_time(base_health_regen_time)

func set_max_stat_value(new_max_stat_value : int) -> void:
	super.set_max_stat_value(new_max_stat_value)
	max_health_updated.emit(max_stat_value)
	set_current_stat_value(max_stat_value)

func set_current_stat_value(new_current_stat_value : int) -> void:
	super.set_current_stat_value(new_current_stat_value)
	health_updated.emit(current_stat_value)

func _set_regen_time(new_regen_time) -> void:
	super._set_regen_time(new_regen_time)

func take_damage(amount: int):
	if !is_dead:
		var current_health = max(current_stat_value - amount, 0)
		set_current_stat_value(current_health)
		_blink_red()
	
		if current_stat_value <= 0:
			is_dead = true
			died.emit()

func _on_upgrade(upgrade : Upgrade) -> void:
	super._on_upgrade(upgrade)
	
	if upgrade.name == "health":
		var new_max_stat_value = base_max_health + upgrade.level * 2
		set_max_stat_value(new_max_stat_value)
	elif upgrade.name == "health_regen":
		if !is_regeneratable:
			is_regeneratable = true
		
		var new_regen_time = base_health_regen_time / upgrade.stat_adapter
		_set_regen_time(new_regen_time)

func _blink_red() -> void:
	if parent != null:
		parent.modulate = Color(1, 0, 0)

		var tween = create_tween()
		tween.tween_property(parent, "modulate", Color(1, 1, 1), 0.2)
