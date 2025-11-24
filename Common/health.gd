extends Node
class_name Health

@export var base_health : float = 10.0
var max_health : float
var current_health : float
var is_dead : bool = false

signal died
signal health_changed(_current_health : float)

func _ready():
	max_health = base_health
	current_health = max_health

func take_damage(amount: float):
	current_health = max(current_health - amount, 0.0)
	health_changed.emit(current_health)
	if current_health <= 0.0 and !is_dead:
		is_dead = true
		died.emit()

func heal(amount: float):
	if current_health < max_health:
		current_health = min(current_health + amount, max_health)
		health_changed.emit(current_health)
