extends Node
class_name Health

@export var base_health : float = 10.0
var max_health : float
var current_health : float

signal died
signal health_changed

func _ready():
	max_health = base_health
	current_health = max_health

func take_damage(amount: float):
	current_health = max(current_health - amount, 0.0)
	emit_signal("health_changed", current_health)
	if current_health <= 0.0:
		emit_signal("died")

func heal(amount: float):
	if current_health < max_health:
		current_health = min(current_health + amount, max_health)
		health_changed.emit(current_health)
