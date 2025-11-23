class_name Upgrade
extends Resource

@export var name : String
@export var price : int
@export var level : int
@export var stat_adapter : float = 1.0
var _base_stat_adapter : float
var _base_adapter_of_stat_adapter : float
var _price_increase : int

func _init(_name : String = "placeholder", _price : int = 2, _level : int = 0, _stat_adapter : float = 1.0, base_stat_adapter : float = 0.3, base_adapter_of_stat_adapter : float = 0.9, base_price_increase : int = 1) -> void:
	name = _name
	price = _price
	level = _level
	stat_adapter = _stat_adapter
	_base_stat_adapter = base_stat_adapter
	_base_adapter_of_stat_adapter = base_adapter_of_stat_adapter
	_price_increase = base_price_increase

func add_level() -> int:
	level += 1
	_update_stat_adapter()
	return _increase_price()

func _increase_price() -> int:
	price += _price_increase
	_increase_price_increase()
	return price

## increases the next price increase
func _increase_price_increase() -> void:
	_price_increase += _price_increase

func _update_stat_adapter() -> void:
	stat_adapter = 1.0
	
	for i in range(0, level):
		stat_adapter += _base_stat_adapter * (_base_adapter_of_stat_adapter ** i)
