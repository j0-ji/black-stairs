extends Node

signal wallet_changed
signal got_poorer
signal got_richer

var wallet : Dictionary

func _ready() -> void:
	reset_or_initialize()

func reset_or_initialize() -> void:
	wallet = {
		"coins" : 10
	}

func add_coin() -> void:
	wallet.coins += 1
	wallet_changed.emit()
	got_richer.emit()

func get_wealth() -> int:
	return wallet.coins

func update_wealth(amount : int) -> int:
	if amount < 0:
		if amount < -wallet.coins:
			amount = -wallet.coins
			push_warning("@dev: player didn't have enough money, please first check if wealth is enough...")
		
		got_poorer.emit()
	
	wallet.coins += amount
	wallet_changed.emit()
	return wallet.coins
