class_name TileMapLayerDataResource
extends NodeDataResource

@export var cell_positions: Array[Vector2i] = []
@export var cell_source_ids: PackedInt32Array = PackedInt32Array()
@export var cell_atlas_coords: Array[Vector2i] = []
@export var cell_alternative_ids: PackedInt32Array = PackedInt32Array()

func _save_data(node: Node2D) -> void:
	super._save_data(node)

	var tilemap_layer := node as TileMapLayer
	if tilemap_layer == null:
		return

	var used_cells: Array[Vector2i] = tilemap_layer.get_used_cells()

	# Clear old data
	cell_positions.clear()
	cell_source_ids.resize(0)
	cell_atlas_coords.clear()
	cell_alternative_ids.resize(0)

	# Store everything needed to reconstruct the tilemap exactly
	for cell in used_cells:
		cell_positions.append(cell)
		cell_source_ids.push_back(tilemap_layer.get_cell_source_id(cell))
		cell_atlas_coords.append(tilemap_layer.get_cell_atlas_coords(cell))
		cell_alternative_ids.push_back(tilemap_layer.get_cell_alternative_tile(cell))


func _load_data(window: Window) -> void:
	var scene_node := window.get_node_or_null(node_path)
	if scene_node == null:
		return

	var tilemap_layer := scene_node as TileMapLayer
	if tilemap_layer == null:
		return

	tilemap_layer.clear()

	var count := cell_positions.size()
	for i in count:
		var coords: Vector2i = cell_positions[i]
		var source_id: int = cell_source_ids[i]
		var atlas_coords: Vector2i = cell_atlas_coords[i]
		var alt_id: int = cell_alternative_ids[i]

		tilemap_layer.set_cell(
			coords,
			source_id,
			atlas_coords,
			alt_id
		)
