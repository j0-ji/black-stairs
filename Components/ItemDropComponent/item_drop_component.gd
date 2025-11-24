extends Node2D

var enemy : CharacterBody2D
var enemies_layer : Node2D
var items_layer : Node2D

const item_coin = preload("res://Entities/Items/Coin/ItemCoin.tscn")

func _ready() -> void:
	enemy = get_parent()
	enemies_layer = enemy.get_parent()
	items_layer = enemies_layer.items_layer
	
	enemy.died.connect(_on_died)

func _on_died(_global_position : Vector2, _coin_amount : int) -> void:
	print("amount of coins to spawn: ", _coin_amount)
	for i in _coin_amount:
		var multiplicator = randi_range(8, 32)
		var base_random_position_modifier = _random_inside_unit_circle()
		var final_random_position_modifier : Vector2 = base_random_position_modifier * multiplicator
		var coin_position : Vector2 = _global_position + final_random_position_modifier
		
		var coin = item_coin.instantiate()
		coin.global_position = coin_position
		items_layer.add_child(coin)

func _random_inside_unit_circle() -> Vector2:
	var theta : float = randf() * 2 * PI
	return Vector2(cos(theta), sin(theta)) * sqrt(randf())
