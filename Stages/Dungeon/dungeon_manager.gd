extends Node2D

@export var map_generator : Node
@export var entrance : Node2D
@export var exit : Node2D
@export var initial_tilemap_layer : TileMapLayer

func _ready() -> void:
	if SaveGameManager.global_data.generate_dungeon:
		map_generator.initiate_generation()
	else:
		SaveGameManager.global_data.generate_dungeon = true
