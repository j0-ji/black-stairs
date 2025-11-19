extends Node

signal wallet_changed

var _coins : int = 10

func add_coin() -> void:
	_coins += 1
	wallet_changed.emit()

func get_wealth() -> int:
	return _coins

func update_wealth(amount : int) -> int:
	_coins += amount
	wallet_changed.emit()
	return _coins
