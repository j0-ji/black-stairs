class_name MapLayer
extends Node

@warning_ignore("unused_signal")
signal transition

@export var tile_map_layer : Node2D

var base_map_size : int
var border_width : int
var map_size : int

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
