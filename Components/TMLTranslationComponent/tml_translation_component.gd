extends Node2D

enum TileType {
	NONE,
	ROCK,
	GRASS,
	DIRT,
	WATER,
	SAND,
}

@export var world_map: TileMapLayer

# 4 TileMapLayers, ordered from bottom to top
@export var display_layers: Array[TileMapLayer]

## For maps that are randomly generated
@export var await_signal : bool = false
## Set if signal is awaited
@export var awaiting_signal_from : Node = null

# Priority from bottom to top (lower number = lower, drawn first)
const TILE_PRIORITY : Dictionary[int, int] = {
	TileType.SAND: 0,
	TileType.WATER: 1,
	TileType.DIRT: 2,
	TileType.GRASS: 3,
	TileType.ROCK: 4,
}

# The 4 neighbours for a single big display tile (dual grid):
# order: [bottom_right, bottom_left, top_right, top_left]
const NEIGHBOURS : Array[Vector2i] = [
	Vector2i(0, 0),  # bottom-right
	Vector2i(1, 0),  # bottom-left
	Vector2i(0, 1),  # top-right
	Vector2i(1, 1),  # top-left
]

# 16 shapes for a single material, indexed by 4-bit mask:
# bit0 = bottom-right, bit1 = bottom-left, bit2 = top-right, bit3 = top-left
const MASK_TO_ATLAS : Array[Vector2i] = [
	# 0b0000 – nothing (usually unused or a "no tile" placeholder)
	Vector2i(0, 3), # 0
	# 0b0001 – bottom-right only
	Vector2i(1, 3), # 1
	# 0b0010 – bottom-left only
	Vector2i(0, 0), # 2
	# 0b0011 – bottom edge
	Vector2i(3, 0), # 3
	# 0b0100 – top-right only
	Vector2i(0, 2), # 4
	# 0b0101 – right edge
	Vector2i(1, 0), # 5
	# 0b0110 – diagonal: bottom-left + top-right
	Vector2i(2, 3), # 6
	# 0b0111 – everything except top-left
	Vector2i(1, 1), # 7
	# 0b1000 – top-left only
	Vector2i(3, 3), # 8
	# 0b1001 – diagonal: bottom-right - top-left
	Vector2i(0, 1), # 9
	# 0b1010 – left edge
	Vector2i(3, 2), # 10
	# 0b1011 – everything except top-right
	Vector2i(2, 0), # 11
	# 0b1100 – top edge
	Vector2i(1, 2), # 12
	# 0b1101 – everything except bottom-left
	Vector2i(2, 2), # 13
	# 0b1110 – everything except bottom-right
	Vector2i(3, 1), # 14
	# 0b1111 – full tile
	Vector2i(2, 1), # 15
]

# Tileset source IDs per material
const MATERIAL_SOURCE_ID : Dictionary[int, int] = {
	TileType.SAND:  0,
	TileType.WATER: 1,
	TileType.DIRT:  2,
	TileType.GRASS: 3,
	TileType.ROCK:  4,
}

func _ready() -> void:
	# Rebuild everything at start.
	if not await_signal:
		_refresh_all_display_tiles()
	elif awaiting_signal_from == null:
		push_error("No signal source set")
	else:
		awaiting_signal_from.translate_tile_map_layer.connect(_refresh_all_display_tiles)
		


# WORK IN PROGRESS FUNCTION - NOT STABLE
# For a mechanic with which the tilemaps can be edited while runtime
# IDEA: explosions, tilled soil would require the world map to change
# this function is intended to set the world tile and auto update
# the display layers
func set_world_tile(coord: Vector2i, t: TileType) -> void:
	# Here you would set the world map cell to some placeholder tile for t,
	# or just store t in an own data structure.
	_set_world_tile_visual(coord, t)

	# Update the 4 display tiles that depend on this world coord
	for offset in NEIGHBOURS:
		var display_coord := coord - offset
		_set_display_tile(display_coord)


# WORK IN PROGRESS FUNCTION - NOT STABLE
# draws the "world" tiles visually [WIP]
func _set_world_tile_visual(coord: Vector2i, t: TileType) -> void:
	if t == TileType.NONE:
		world_map.set_cell(coord, -1)
		return
		
	var atlas_coord := Vector2i.ZERO # TODO: pick based on t
	var tileset_source_id = 1
	world_map.set_cell(coord, tileset_source_id, atlas_coord)


func _refresh_all_display_tiles() -> void:
	# Assumes the world_map is a finer grid.
	var used := world_map.get_used_cells()
	var display_done := {}
	for world_coord in used:
		var display_coord := Vector2i(world_coord.x, world_coord.y)
		
		if display_done.has(display_coord):
			continue
		
		display_done[display_coord] = true
		_set_display_tile(display_coord)


func _set_display_tile(display_coord: Vector2i) -> void:
	# Clear the 4 display layers at this coord
	for layer in display_layers:
		layer.set_cell(display_coord, -1)
	
	# Get the 4 world materials for this tile (one per corner)
	var corner_types: Array[TileType] = []
	for offset in NEIGHBOURS:
		var wc := display_coord + offset
		corner_types.append(_get_world_tile_type(wc))
	
	# Gather unique materials, excluding NONE
	var unique_materials: Array[int] = []
	for t in corner_types:
		if t == TileType.NONE:
			continue
		if not unique_materials.has(t):
			unique_materials.append(t)

	# check if one of the 4 corners is water
	var has_water := false
	for t in corner_types:
		if t == TileType.WATER:
			has_water = true
			break
	
	# if theres water, also add sand to be displayed under it
	if has_water and not unique_materials.has(TileType.SAND):
		unique_materials.append(TileType.SAND)
	
	# Sort materials by priority (bottom to top)
	unique_materials.sort_custom(Callable(self, "_sort_materials_by_priority"))
	
	# For each material, compute mask and draw on its layer
	# If there are more than 5 materials somehow, only first 5 will be drawn.
	var max_layers : int = min(unique_materials.size(), display_layers.size())
	for i in range(max_layers):
		var ground_material: int = unique_materials[i]
		var mask := _compute_mask_for_material(ground_material, corner_types)
		
		# add the water mask to the sand mask if both are on the same tile, to display sand also under the water
		if has_water and ground_material == TileType.SAND:
			var water_mask := _compute_mask_for_material(TileType.WATER, corner_types)
			mask = mask | water_mask
		
		if mask == 0:
			continue # this material not present on corners
		
		var shape_atlas : Vector2i = MASK_TO_ATLAS[mask]
		var source_id : int = MATERIAL_SOURCE_ID[ground_material]
		var layer : TileMapLayer = display_layers[i]
		layer.set_cell(display_coord, source_id, shape_atlas)


func _sort_materials_by_priority(a: int, b: int) -> bool:
	return TILE_PRIORITY[a] < TILE_PRIORITY[b]


func _compute_mask_for_material(ground_material: int, corner_types: Array[TileType]) -> int:
	var mask := 0
	
	# order: [br, bl, tr, tl] matching NEIGHBOURS
	if corner_types[0] == ground_material: mask |= 1 << 3 # bottom-right
	if corner_types[1] == ground_material: mask |= 1 << 2 # bottom-left
	if corner_types[2] == ground_material: mask |= 1 << 1 # top-right
	if corner_types[3] == ground_material: mask |= 1 << 0 # top-left
	
	return mask


## translates the world tile to a TileType
func _get_world_tile_type(coord: Vector2i) -> int:
	var atlas_coord := world_map.get_cell_atlas_coords(coord)
	
	if atlas_coord == Vector2i(-1, -1):
		return TileType.NONE
	elif atlas_coord == Vector2i(0, 0):
		return TileType.SAND
	elif atlas_coord == Vector2i(1, 0):
		return TileType.GRASS
	elif atlas_coord == Vector2i(2, 0):
		return TileType.DIRT
	elif atlas_coord == Vector2i(3, 0):
		return TileType.WATER
	else:
		return TileType.ROCK
