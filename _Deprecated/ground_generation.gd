extends TileMapLayer

# Signals
signal generation_done

# Flags
@export var feature_flag_hole_filling = true

# Global world_gen_config.gd file
var base_map_size : int = WorldGenConfig.base_map_size
var border_width : int = WorldGenConfig.border_width

# Map gen variables
var border_base_additive: float = border_width * pow(1.2 * border_width, -2)
var border_base_multiplicator: float = 1 + border_base_additive / 0.2
var map_width: int = (base_map_size + 2 * border_width)
var map_height: int = (base_map_size + 2 * border_width)
var noise_scale: float = 1.0    # Bigger = smoother continents
var noise_seed: int = 12345
var frequency: float = 0.0125  # 0.0125 Base frequency for FNL
var octaves: int = 4
var lacunarity: float = 2.1
var gain: float = 0.5

# TileSet atlas info
var atlas_source_id: int = 1  # <- check in the TileSet inspector

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
	ground_type_map.resize(map_width * map_height)

func _configure_noise() -> void:
	# Update seed
	if custom_seed_id in range(custom_seeds.size()):
		noise_seed = custom_seeds[custom_seed_id]
		custom_seed_id = custom_seed_id + 1
	else:
		noise_seed = randi()
	
	# Noise configuration
	_noise.seed = noise_seed
	_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	_noise.frequency = frequency
	_noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	_noise.fractal_octaves = octaves
	_noise.fractal_lacunarity = lacunarity
	_noise.fractal_gain = gain

func generate_world() -> void:
	_configure_noise()
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

# types-array contains the ground type (e.g., ground.GRASS, ground.ROCK, etc.)
# Call this after you’ve generated `types` and before writing cells to the TileMap.
func _prune_rock_holes(types: PackedByteArray, min_keep_size := INF, keep_pos: Vector2i = Vector2i(-1, -1)) -> void:
	var visited := PackedByteArray()
	visited.resize(map_width * map_height)

	var components: Array = []  # each item: {cells: PackedVector2Array, size: int}
	
	var keep_component_i := -1
	
	var floor_types_to_fill_out = [
		ground.ROCK
	]
	
	# STEP 1: find all components
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
					if _in_bounds(n) and visited[_idx(n)] == 0 and types[_idx(n)] not in floor_types_to_fill_out:
						visited[_idx(n)] = 1
						q.push_back(n)

			components.append({ "cells": comp_cells, "size": comp_cells.size() })

	# STEP 2: decide which component to keep
	if components.is_empty():
		return

	# keep the component that contains keep_pos (e.g. the spawn or map center)
	if keep_pos != Vector2i(-1, -1):
		for i in range(components.size()):
			# cheap membership test
			for c in components[i]["cells"]:
				if c == keep_pos:
					keep_component_i = i
					break
			if keep_component_i != -1:
				break
	
	# otherwise: keep the largest component as the mainland
	if keep_component_i == -1:
		var best_i := 0
		var best_sz : int = components[0]["size"]
		for i in range(1, components.size()):
			if components[i]["size"] > best_sz:
				best_i = i
				best_sz = components[i]["size"]
		keep_component_i = best_i

	# Convert all other components that are too small into ROCK
	for i in range(components.size()):
		if i == keep_component_i: continue
		if components[i]["size"] >= min_keep_size: continue  # optional: allow multiple big continents
		for c in components[i]["cells"]:
			types[_idx(c)] = floor_types_to_fill_out[0]

func _idx (p: Vector2i) -> int: 
	return p.y * map_width + p.x

func _in_bounds (p: Vector2i) -> bool: 
	return p.x >= 0 and p.y >= 0 and p.x < map_width and p.y < map_height
