extends Node
class_name Health

@export var max_health := 10.0
var current_health := max_health

signal died
signal health_changed(new_value: float)

func _ready():
	current_health = max_health

func take_damage(amount: float):
	current_health = max(current_health - amount, 0.0)
	emit_signal("health_changed", current_health)
	if current_health <= 0.0:
		emit_signal("died")

func heal(amount: float):
	current_health = min(current_health + amount, max_health)
	emit_signal("health_changed", current_health)
