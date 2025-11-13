class_name Player
extends CharacterBody2D

var move_direction: Vector2
var anim_direction: Vector2
@export var speed : int = 100
@export var camera : Camera2D

func _ready() -> void:
	if camera:
		camera.make_current()
