extends MapLayer

@export var _ground : TileMapLayer
@export var _flora : TileMapLayer

@export var _entrance : Node2D
@export var _exit : Area2D

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

func initialize() -> void:
	pass

func generate() -> void:
	var spawn_dict : Dictionary = _find_spawn()
	var exit_point : Vector2i = _find_exit(spawn_dict.coord)
	
	var entrance_local : Vector2i = _ground.to_local(spawn_dict.coord)
	var exit_local : Vector2i = _ground.to_local(exit_point)
	
	_entrance.global_position = entrance_local * 16
	_exit.global_position = exit_local * 16

	_entrance.get_child(0).global_rotation_degrees = spawn_dict.rotation_degrees

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
