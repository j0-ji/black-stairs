extends TileMapLayer

# FLora & Ground layer path - used to read generated ground and fauna data
var ground_layer_path = "../Ground"
@onready var _ground: TileMapLayer = get_node(ground_layer_path) as TileMapLayer
var flora_layer_path = "../Flora"
@onready var _flora: TileMapLayer = get_node(flora_layer_path) as TileMapLayer

# From external world_gen_config.gd file
var base_map_size : int = WorldGenConfig.base_map_size
var border_width : int = WorldGenConfig.border_width
var map_size = base_map_size + 2 * border_width

# TileSet atlas info
@export var atlas_source_id: int = 0

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
	},
	{
		"dir": Vector2i(1, 0),
		"base": Vector2i(0, 1),
		"base_additive": Vector2i(0, 0),
	},
	{
		"dir": Vector2i(0, -1),
		"base": Vector2i(1, 0),
		"base_additive": Vector2i(0, map_size - 1),
	},
	{
		"dir": Vector2i(-1, 0),
		"base": Vector2i(0, 1),
		"base_additive": Vector2i((map_size - 1), 0)
	},
]

# first border cell
# check xy cells 
# go to next - not already checked - border cell

func _ready() -> void:
	_flora.generation_done.connect(_on_flora_generation_done)
	_on_flora_generation_done()

func _on_flora_generation_done () -> void:
	self.clear()
	var spawn_point = _find_spawn()
	var atlas_coords := Vector2i(5, 0)
	set_cell(spawn_point, atlas_source_id, atlas_coords)
	
	var exit_point = _find_exit(spawn_point)
	set_cell(exit_point, atlas_source_id, atlas_coords)

func _find_spawn() -> Vector2i:
	var rng = RandomNumberGenerator.new()
	var side = rng.randi_range(0, 3)
	var base_multiplicator = rng.randi_range(border_width - 1, map_size - border_width - 1)
	var base : Vector2i
	
	var found = false
	for i in range(directions.size()):
		if found: continue
		
		var skip = false
		side += i
		side = side % 4
		
		base = directions[side].base * base_multiplicator + directions[side].base_additive
		
		while not found and not skip:
			if valid_grounds.has(_ground.get_cell_atlas_coords(base + directions[side].dir)):
				if _flora.get_cell_atlas_coords(base + directions[side].dir) != Vector2i(-1, -1):
					skip = true
				else:
					found = true
			else:
				base += directions[side].dir
	
	return base

func _find_exit(spawn_point : Vector2i) -> Vector2i:
	var rng = RandomNumberGenerator.new()
	var found = false
	var candidate : Vector2i
	while not found:
		candidate = Vector2i(rng.randi_range(1, map_size - 2), rng.randi_range(1, map_size - 2))
		var ground_at_candidate = _ground.get_cell_atlas_coords(candidate)
		@warning_ignore("integer_division")
		if spawn_point.distance_to(candidate) >= ((map_size - (map_size % 2)) / 2) and ground_at_candidate != Vector2i(4, 0):
			found = true
	return candidate
