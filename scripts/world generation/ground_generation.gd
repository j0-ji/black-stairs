extends TileMapLayer

# Signals
signal generation_done

# Flags
@export var feature_flag_hole_filling = true

# Map gen config
@export var border_width: int = 20 # min width 5
@export var border_base_additive: float = border_width * pow(1.2 * border_width, -2)
@export var border_base_multiplicator: float = 1 + border_base_additive / 0.2
@export var base_map_size: int = 64
var map_width: int = (base_map_size + 2 * border_width)
var map_height: int = (base_map_size + 2 * border_width)
@export var noise_scale: float = 1.0    # Bigger = smoother continents
@export var ground_seed: int = 12345
@export var frequency: float = 0.0125  # 0.0125 Base frequency for FNL
@export var octaves: int = 4
@export var lacunarity: float = 2.1
@export var gain: float = 0.5

# TileSet atlas info
@export var atlas_source_id: int = 1  # <- check in the TileSet inspector
# X-atlas coordinates in the atlas grid for the different grounds
enum ground {
	SAND = 0,
	GRASS = 1,
	DIRT = 2,
	WATER = 3,
	ROCK = 4,
}

# Thresholds decide biome by noise value in [-1, 1]
@export var t_water: float = -0.35
@export var t_sand:  float =  -0.25
@export var t_grass: float =  0.4
# >= t_grass becomes rock

# used for post processing of map generation
var ground_type_map := PackedByteArray()

var custom_seed_id : int = 0
var custom_seeds : Array = [
	1695529641,
	3707740996,
	4119726360,
	2332203375, # PERFECT EXAMPLE
	606869515,
	1447267684,
	3258134911,
]

var _noise := FastNoiseLite.new()

func _ready() -> void:
	print(border_width)
	print(border_base_additive)
	print(border_base_multiplicator)
	
	ground_type_map.resize(map_width * map_height)
	_configure_noise()
	generate_world()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and event.keycode == KEY_R):
		if custom_seed_id in range(custom_seeds.size()):
			ground_seed = custom_seeds[custom_seed_id]
			custom_seed_id = custom_seed_id + 1
		else:
			ground_seed = randi()
		print(ground_seed)
		_configure_noise()
		generate_world()

func _configure_noise() -> void:
	_noise.seed = ground_seed
	_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	_noise.frequency = frequency
	_noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	_noise.fractal_octaves = octaves
	_noise.fractal_lacunarity = lacunarity
	_noise.fractal_gain = gain

func generate_world() -> void:
	self.clear()
	
	# BETTER GROUND GENERATION
	# STEP 1.1: generate noise map
	# STEP 1.2: translate noise map to valid ground types
	for y in range(map_height):
		for x in range(map_width):
			var mult := _get_multiplier(x, y)
			var n := _noise.get_noise_2d(float(x) / noise_scale, float(y) / noise_scale)
			var ground_type = _pick_tile(n + (border_base_additive * mult))
			var p = Vector2i(x, y)
			ground_type_map[_idx(p)] = ground_type
			
	# STEP 2: post gen processing
	if feature_flag_hole_filling:
		_prune_rock_holes(ground_type_map)
	
	# STEP 3: write processed map information to the TileMapLayer
	for y in map_height:
		for x in map_width:
			_update_cell(x, y)
	
	update_internals()
	generation_done.emit()

func _pick_tile(n: float) -> int:
	# n is in [-1, 1]
	if n < t_water:
		return ground.WATER
	elif n < t_sand:
		return ground.SAND
	elif n < t_grass:
		return ground.GRASS
	else:
		return ground.ROCK

func _update_cell(x, y):
	var ground_type : int = ground_type_map[_idx(Vector2i(x, y))]
	var atlas_coords := Vector2i(ground_type, 0)
	set_cell(Vector2i(x, y), atlas_source_id, atlas_coords)

func _get_multiplier(x, y) -> float:
	var mult: float = 0.0
	var mult_y: float = 0.0
	var mult_x: float = 0.0
	
	var mult_variance := 0.98
	
	if y < border_width:
		mult_y = pow(border_base_multiplicator, (border_width - y) / mult_variance)
	elif y > (map_width - (border_width + 1)):
		mult_y = pow(border_base_multiplicator, (border_width - (map_height - (y+1))) / mult_variance )
	
	if x < border_width:
		mult_x = pow(border_base_multiplicator, (border_width - x) / mult_variance)
	elif x > (map_height - (border_width + 1)):
		mult_x = pow(border_base_multiplicator, (border_width - (map_width - (x+1))) / mult_variance)

	if mult_y >= mult_x:
		mult = mult_y
	else:
		mult = mult_x
	
	return mult

# types[y][x] contains your ground type (e.g., enum {ROCK=0, GRASS=1, ...})
# Call this after you’ve generated `types` and before writing cells to the TileMap.
func _prune_rock_holes(types: PackedByteArray, min_keep_size := INF, keep_pos: Vector2i = Vector2i(-1, -1)) -> void:
	var visited := PackedByteArray()
	visited.resize(map_width * map_height)

	var holes: Array = []  # each item: {cells: PackedVector2Array, size: int}
	
	var keep_component_i := -1
	
	var floor_types_to_fill_out = [
		ground.ROCK
	]
	
	for y in range(map_height):
		for x in range(map_width):
			var p := Vector2i(x, y)
			if types[_idx(p)] in floor_types_to_fill_out: continue
			if visited[_idx(p)] == 1: continue

			# BFS collect this component
			var q : Array = [p]
			var comp_cells := PackedVector2Array()
			visited[_idx(p)] = 1

			while q.size() > 0:
				var c : Vector2i = q.pop_back()
				comp_cells.push_back(c)

				for d in [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]:
					var n : Vector2i = c + d
					if _in_bounds(n) and visited[_idx(n)] == 0 and types[_idx(Vector2i(n.x, n.y))] not in floor_types_to_fill_out:
						visited[_idx(n)] = 1
						q.push_back(n)

			holes.append({ "cells": comp_cells, "size": comp_cells.size() })

	# Decide which component to keep
	if holes.is_empty():
		return

	if keep_pos != Vector2i(-1, -1):
		# keep the component that contains keep_pos (e.g. your spawn or map center)
		for i in range(holes.size()):
			# cheap membership test
			for c in holes[i]["cells"]:
				if c == keep_pos:
					keep_component_i = i
					break
			if keep_component_i != -1:
				break

	if keep_component_i == -1:
		# otherwise: keep the largest component as the mainland
		var best_i := 0
		var best_sz : int = holes[0]["size"]
		for i in range(1, holes.size()):
			if holes[i]["size"] > best_sz:
				best_i = i
				best_sz = holes[i]["size"]
		keep_component_i = best_i

	# Convert all other components that are too small into ROCK
	for i in range(holes.size()):
		if i == keep_component_i: continue
		if holes[i]["size"] >= min_keep_size: continue  # optional: allow multiple big continents
		for c in holes[i]["cells"]:
			types[_idx(Vector2i(c.x, c.y))] = floor_types_to_fill_out[0]

func _idx (p: Vector2i) -> int: 
	return p.y * map_width + p.x

func _in_bounds (p: Vector2i) -> bool: 
	return p.x >= 0 and p.y >= 0 and p.x < map_width and p.y < map_height
