extends Node

# FLora & Ground layer path - used to read generated ground and fauna data
var ground_layer_path = "../Ground"
@onready var _ground: TileMapLayer = get_node(ground_layer_path) as TileMapLayer
var flora_layer_path = "../Flora"
@onready var _flora: TileMapLayer = get_node(flora_layer_path) as TileMapLayer
# CURRETNLY ONLY FOR DEBUG PURPOSES
var stuff_layer_path = "../Stuff"
@onready var _stuff: TileMapLayer = get_node(stuff_layer_path) as TileMapLayer

const EntranceScene := preload("res://scenes/stuff/map_io/Entrance.tscn")
const ExitScene := preload("res://scenes/stuff/map_io/Exit.tscn")

var entrance := EntranceScene.instantiate()
var exit := ExitScene.instantiate()

# From external world_gen_config.gd file
var base_map_size : int = WorldGenConfig.base_map_size
var border_width : int = WorldGenConfig.border_width
var map_size = base_map_size + 2 * border_width

var valid_grounds = [
	Vector2i(0, 0),
	Vector2i(1, 0),
	Vector2i(2, 0),
]

var directions = [
	{
		"dir": Vector2i(0, 1),
		"base": Vector2i(1, 0),
		"base_additive": Vector2i(0, 0),
		"rotation_degrees": 0,
	},
	{
		"dir": Vector2i(1, 0),
		"base": Vector2i(0, 1),
		"base_additive": Vector2i(0, 0),
		"rotation_degrees": 270,
	},
	{
		"dir": Vector2i(0, -1),
		"base": Vector2i(1, 0),
		"base_additive": Vector2i(0, map_size - 1),
		"rotation_degrees": 180,
	},
	{
		"dir": Vector2i(-1, 0),
		"base": Vector2i(0, 1),
		"base_additive": Vector2i((map_size - 1), 0),
		"rotation_degrees": 90,
	},
]

# first border cell
# check xy cells 
# go to next - not already checked - border cell

func _ready() -> void:
	add_child(entrance)
	add_child(exit)

func generate_world () -> void:
	var spawn_dict : Dictionary = _find_spawn()
	var exit_point : Vector2i = _find_exit(spawn_dict.coord)
	
	var entrance_local : Vector2i = _ground.to_local(spawn_dict.coord)
	var exit_local : Vector2i = _ground.to_local(exit_point)
	
	entrance.global_position = entrance_local * 16
	exit.global_position = exit_local * 16

	entrance.get_child(0).global_rotation_degrees = spawn_dict.rotation_degrees
	
	# _stuff.clear()
	# var atlas_source_id = 0
	# var atlas_coords := Vector2i(5, 0)
	# _stuff.set_cell(spawn_dict.coord, atlas_source_id, atlas_coords)
	# _stuff.set_cell(exit_point, atlas_source_id, atlas_coords)

func _find_spawn() -> Dictionary:
	var rng = RandomNumberGenerator.new()
	var side = rng.randi_range(0, 3)
	var base_multiplicator = rng.randi_range(border_width - 1, map_size - border_width - 1)
	var base : Vector2i
	var dir : Vector2i
	var rotation_degrees : int
	
	var found = false
	for i in range(directions.size()):
		if found: continue
		
		var skip = false
		side += i
		side = side % 4
		dir = directions[side].dir
		
		base = directions[side].base * base_multiplicator + directions[side].base_additive
		rotation_degrees = directions[side].rotation_degrees
		
		while not found and not skip:
			if valid_grounds.has(_ground.get_cell_atlas_coords(base + dir)):
				if _flora.get_cell_atlas_coords(base + dir) != Vector2i(-1, -1):
					skip = true
				else:
					found = true
			else:
				base += dir
	
	return {"coord" : base, "dir" : dir, "rotation_degrees": rotation_degrees}

func _find_exit(spawn_point : Vector2i) -> Vector2i:
	var rng = RandomNumberGenerator.new()
	var found = false
	var candidate : Vector2i
	while not found:
		candidate = Vector2i(rng.randi_range(1, map_size - 2), rng.randi_range(1, map_size - 2))
		var ground_at_candidate = _ground.get_cell_atlas_coords(candidate)
		@warning_ignore("integer_division") # handled via modul division, but not recognized by IDE
		if spawn_point.distance_to(candidate) >= ((map_size - (map_size % 2)) / 2) and ground_at_candidate != Vector2i(4, 0):
			found = true
	return candidate
