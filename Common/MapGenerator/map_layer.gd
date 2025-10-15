class_name MapLayer
extends Node

@warning_ignore("unused_signal")
signal transition

@export var map_layer : Node2D

var base_map_size : int
var border_width : int
var map_size : int

# X-atlas coordinates in the atlas grid for the different grounds
# Also used for identifying tpye of ground in some layers
enum ground_type {
	SAND = 0,
	GRASS = 1,
	DIRT = 2,
	WATER = 3,
	ROCK = 4,
}

func setup(_base_map_size : int, _border_width : int):
	base_map_size = _base_map_size
	border_width = _border_width
	map_size = base_map_size + 2 * border_width

## Used for initializing individual calculated variables that rely on the setup 
## variables. Can also be used for other layer-specific initialization logic.
func initialize() -> void:
	pass

func generate() -> void:
	pass
