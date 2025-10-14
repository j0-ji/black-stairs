class_name MapGenerator
extends Node

signal generation_done

@export var initial_map_layer : MapLayer
@export var base_map_size : int = 32
@export var border_width : int = 20

var map_layers : Array[MapLayer] = []
var current_layer : int = 0

func _ready() -> void:
	for child in get_children():
		if child is MapLayer:
			map_layers.append(child)
			child.transition.connect(transition)
			child.setup(base_map_size, border_width)
			child.initialize()

func initiate_generation() -> void:
	print("MAP_GENERATOR: map generation initiated")
	map_layers[current_layer].generate()

func transition():
	current_layer += 1
	
	print("MAP_GENERATOR: generated layer: ", current_layer)
	
	if current_layer >= map_layers.size():
		generation_done.emit()
		print("MAP_GENERATOR: map generation done")
		return
	
	map_layers[current_layer].generate()
