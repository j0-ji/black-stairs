extends Node2D

@export var sprite_rotation : int = 0

var spawn_point := Vector2i(0, 0)

var _pos_0 := Vector2i(8, 24)
var _pos_90 := Vector2i(-8, 8)
var _pos_180 := Vector2i(8, -8)
var _pos_270 := Vector2i(24, 8)

func _ready() -> void:
	pass

func _get_relative_spawn() -> Vector2i:
	if sprite_rotation == 0:
		return _pos_0
	elif sprite_rotation == 90:
		return _pos_90
	elif sprite_rotation == 180:
		return _pos_180
	elif sprite_rotation == 270:
		return _pos_270
	else:
		push_error("Invalid rotation of entrance encountert")
		# maybe find a way to not return anything in case of error ?
		return _pos_0

func _get_global_spawn() -> Vector2i:
	return self.position as Vector2i + _get_relative_spawn()

func update_spawn_point() -> void:
	spawn_point = _get_global_spawn()
