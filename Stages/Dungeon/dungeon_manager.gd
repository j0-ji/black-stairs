extends Node2D

@export var map_generator : Node
@export var entrance : Node2D
@export var exit : Node2D

var amount_of_bosses : int = 0
var died_bosses : int = 0

func _ready() -> void:
	map_generator.initiate_generation()

func register_boss(boss : CharacterBody2D) -> void:
	if !exit.is_locked:
		exit.lock()
		
	boss.died.connect(_on_boss_died)
	amount_of_bosses += 1

func _on_boss_died(_pos : Vector2, _coins : int) -> void:
	died_bosses += 1
	
	if died_bosses == amount_of_bosses:
		exit.unlock()
