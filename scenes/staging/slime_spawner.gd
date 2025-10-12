extends Node2D

@export var slime_count := 5
@export var goblin_count := 3
@export var slime_scene: PackedScene
@export var goblin_scene: PackedScene
@export var cell_size := Vector2(64, 64)
@export var map_width := 1600
@export var map_height := 1600
@export var player_path: NodePath  # so we can assign it to spawned enemies

func _ready():

	# Spawn slimes
	for i in range(slime_count):
		var slime_instance = slime_scene.instantiate()
		slime_instance.position = _random_position()
		get_tree().current_scene.add_child.call_deferred(slime_instance)
		print("Spawned slime at: ", slime_instance.position)

	# Spawn goblins
	for i in range(goblin_count):
		var goblin_instance = goblin_scene.instantiate()
		goblin_instance.position = _random_position()
		get_tree().current_scene.add_child.call_deferred(goblin_instance)
		print("Spawned goblin at: ", goblin_instance.position)

func _random_position() -> Vector2:
	return Vector2(
		randf_range(0, map_width),
		randf_range(0, map_height)
	)
