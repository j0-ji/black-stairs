class_name Upgrade

var price : int
var level : int = 0
var multiplicator : float = 1.0
var _base_multiplicator : float
var _base_multiplicator_adaptor : float = 0.9
var _price_increase : int

func _init(base_price : int = 2, base_multiplicator : float = 0.05, base_price_increase : int = 1) -> void:
	price = base_price
	_base_multiplicator = base_multiplicator
	_price_increase = base_price_increase

func add_level() -> int:
	level += 1
	_update_multiplicator()
	return _increase_price()

func _increase_price() -> int:
	price += _price_increase
	_increase_price_increase()
	return price

## increases the next price increase
func _increase_price_increase() -> void:
	_price_increase += _price_increase

func _update_multiplicator() -> void:
	multiplicator = 1.0
	
	for i in range(0, level):
		multiplicator += _base_multiplicator * (_base_multiplicator_adaptor ** i)
