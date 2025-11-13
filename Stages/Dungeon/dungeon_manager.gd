extends Node2D

@export var map_generator : Node
@export var entrance : Node2D
@export var exit : Area2D

func _ready() -> void:
	map_generator.initiate_generation()
