extends Node2D

@export var spawn_marker : Marker2D
var spawn_point : Vector2i

func _ready() -> void:
	spawn_point = spawn_marker.global_position
