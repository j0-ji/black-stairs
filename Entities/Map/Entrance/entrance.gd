extends Node2D

@export var _sprite : Sprite2D

var spawn_point : Vector2i

var pos_sprite := Vector2i(8, 8)

var pos_0 := Vector2i(8, 24)
var pos_90 := Vector2i(-8, 8)
var pos_180 := Vector2i(8, -8)
var pos_270 := Vector2i(24, 8)

func get_relative_spawn() -> Vector2i:
	if _sprite.rotation == 0:
		return pos_0
	elif _sprite.rotation == 90:
		return pos_90
	elif _sprite.rotation == 180:
		return pos_180
	elif _sprite.rotation == 270:
		return pos_270
	else:
		push_error("Invalid rotation of entrance encountert")
		# maybe find a way to not return anything in case of error ?
		return pos_0
