class_name MapGenerator
extends Node

@export var initial_map_layer : MapLayer
@export var base_map_size : int = 32
@export var border_width : int = 20

var map_layers : Dictionary = {}
var current_map_layer : MapLayer
var current_map_layer_name : String

func _ready() -> void:
	for child in get_children():
		if child is MapLayer:
			map_layers[child.name.to_lower()] = child
			child.transition.connect(transition_to)
			child.setup(base_map_size, border_width)
			child.initialize()
	
	if initial_map_layer:
		initial_map_layer.generate()
		current_map_layer = initial_map_layer

func transition_to(map_layer_name : String):
	if map_layer_name.to_lower() == current_map_layer_name.to_lower():
		push_error("Cannot transition to the same map layer generation step again: ", map_layer_name)
		return
	
	var new_map_layer = map_layers.get(map_layer_name.to_lower())
	
	if new_map_layer == null:
		push_warning("Invalid map layer name: ", map_layer_name)
		return
	
	current_map_layer = new_map_layer
	current_map_layer_name = map_layer_name.to_lower()
	print("Current map layer: ", current_map_layer_name)
	
	new_map_layer.generate()
