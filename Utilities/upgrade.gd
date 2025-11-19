class_name Upgrade

var price : int
var level : int = 0
var multiplier : float = 1.0
var _base_multiplier : float
var _base_multiplier_adapter : float = 0.9
var _price_increase : int

func _init(base_price : int = 2, base_multiplier : float = 0.05, base_price_increase : int = 1) -> void:
	price = base_price
	_base_multiplier = base_multiplier
	_price_increase = base_price_increase

func add_level() -> int:
	level += 1
	_update_multiplier()
	return _increase_price()

func _increase_price() -> int:
	price += _price_increase
	_increase_price_increase()
	return price

## increases the next price increase
func _increase_price_increase() -> void:
	_price_increase += _price_increase

func _update_multiplier() -> void:
	multiplier = 1.0
	
	for i in range(0, level):
		multiplier += _base_multiplier * (_base_multiplier_adapter ** i)
