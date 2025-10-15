extends MapLayer

@export var _ground : TileMapLayer
@export var _flora : TileMapLayer
@export var _io : Node2D # TODO: check if enemy spawn is too close to player spawn

@export var slime_count := 5
@export var goblin_count := 3
@export var slime_scene: PackedScene
@export var goblin_scene: PackedScene



func _ready() -> void:
	pass

func initialize() -> void:
	pass

func generate() -> void:
	# Spawn slimes
	for i in range(slime_count):
		# get position and check if it's valid, otherwise don't even spawn slime...
		var pos = _random_position()
		if pos == Vector2i(-1, -1):
			continue
			
		var slime_instance = slime_scene.instantiate()
		slime_instance.position = pos
		map_layer.add_child.call_deferred(slime_instance)
		print("Spawned slime at: ", slime_instance.position)
	
	# Spawn goblins
	for i in range(goblin_count):
		var pos = _random_position()
		if pos == Vector2i(-1, -1):
			continue
		
		var goblin_instance = goblin_scene.instantiate()
		goblin_instance.position = pos
		map_layer.add_child.call_deferred(goblin_instance)
		print("Spawned goblin at: ", goblin_instance.position)
	
	transition.emit()

func _random_position() -> Vector2i:
	var pos = Vector2i(-1, -1)
	var max_attempts : int = 1000
	var attempts : int = 0
	var valid = false
	
	while not valid and attempts < max_attempts:
		pos = Vector2i(
			randi_range(0, map_size - 1),
			randi_range(0, map_size - 1),
		)
		valid = _is_pos_valid(pos)
		attempts += 1
	
	if not valid:
		push_warning("Could not find a valid random position after %d attempts." % max_attempts)
		return Vector2i(-1, -1)
	
	var s = _ground.tile_set.tile_size
	return Vector2i(pos.x * s.x, pos.y * s.y)

func _is_pos_valid(_pos : Vector2i) -> bool:
	if _valid_ground(_pos) and _flora.get_cell_atlas_coords(_pos) == Vector2i(-1, -1):
		return true
	else: return false

func _valid_ground(_pos) -> bool:
	var cell = _ground.get_cell_atlas_coords(_pos)
	if cell.x == ground_type.SAND or cell.x == ground_type.GRASS or cell.x == ground_type.DIRT:
		return true
	else: return false
