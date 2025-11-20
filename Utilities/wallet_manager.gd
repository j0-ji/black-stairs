extends Node

signal wallet_changed
signal got_poorer

var _coins : int = 10

func add_coin() -> void:
	_coins += 1
	wallet_changed.emit()

func get_wealth() -> int:
	return _coins

func update_wealth(amount : int) -> int:
	if amount < 0:
		if amount < -_coins:
			amount = -_coins
			push_error("player didn't have enough money, please first check if wealth is enough...")
		
		got_poorer.emit()
	
	_coins += amount
	wallet_changed.emit()
	return _coins
