extends MapLayer

@export var _dungeon : Node2D
@export var _ground : TileMapLayer
@export var _flora : TileMapLayer
@export var _io : Node2D # TODO: check if enemy spawn is too close to player spawn

@export var slime_count := 0
@export var goblin_count := 0
@export var variant_goblin_count := 0
@export var boss_count := 0
@export var slime_scene: PackedScene
@export var goblin_scene: PackedScene
@export var goblin_variant_scene: PackedScene
@export var goblin_boss_scene: PackedScene

const default_enemy_counts_per_level = {
	1 : {
		"slime_count" : 10,
		"goblin_count" : 4,
		"variant_goblin_count" : 0,
		"boss_count" : 0,
	},
	2 : {
		"slime_count" : 9,
		"goblin_count" : 7,
		"variant_goblin_count" : 5,
		"boss_count" : 0,
	},
	3: {
		"slime_count" : 7,
		"goblin_count" : 8,
		"variant_goblin_count" : 8,
		"boss_count" : 0,
	},
	4: {
		"slime_count" : 6,
		"goblin_count" : 10,
		"variant_goblin_count" : 10,
		"boss_count" : 0,
	},
	5: {
		"slime_count" : 5,
		"goblin_count" : 8,
		"variant_goblin_count" : 8,
		"boss_count" : 1,
	}
}

func _ready() -> void:
	pass

func initialize() -> void:
	if slime_count == 0 and goblin_count == 0 and variant_goblin_count == 0 and boss_count == 0:
		if SaveGameManager.global_data.current_dungeon_level <= 5:
			var current_level = SaveGameManager.global_data.current_dungeon_level
			var current_enemy_counts = default_enemy_counts_per_level[current_level]
			
			# assign enemy counts
			slime_count = current_enemy_counts.slime_count
			goblin_count = current_enemy_counts.goblin_count
			variant_goblin_count = current_enemy_counts.variant_goblin_count
			boss_count = current_enemy_counts.boss_count

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
		
	for i in range(variant_goblin_count):
		var pos = _random_position()
		if pos == Vector2i(-1, -1):
			continue
		
		var goblin_variant_instance = goblin_variant_scene.instantiate()
		goblin_variant_instance.position = pos
		map_layer.add_child.call_deferred(goblin_variant_instance)
		print("Spawned variant goblin at: ", goblin_variant_instance.position)
		
	for i in range(boss_count):
		var pos = _random_position()
		if pos == Vector2i(-1, -1):
			continue
		
		var goblin_boss_scene_instance = goblin_boss_scene.instantiate()
		goblin_boss_scene_instance.position = pos
		map_layer.add_child.call_deferred(goblin_boss_scene_instance)
		_dungeon.register_boss(goblin_boss_scene_instance)
		print("Spawned boss goblin at: ", goblin_boss_scene_instance.position)
	
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
