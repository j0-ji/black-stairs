extends Node2D

@export var entrance : Node2D
@export var exit : Area2D

func _ready() -> void:
	entrance.update_spawn_point()
