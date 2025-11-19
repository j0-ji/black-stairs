class_name Upgrade

var price : int
var count : int = 0
var _price_increase : int

func _init(base_price : int = 2, base_price_increase : int = 1) -> void:
	price = base_price
	_price_increase = base_price_increase

func add_level() -> int:
	count += 1
	return _increase_price()

func _increase_price() -> int:
	price += _price_increase
	_increase_price_increase()
	return price

## increases the next price increase
func _increase_price_increase() -> void:
	_price_increase += _price_increase
