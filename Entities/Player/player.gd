class_name Player
extends CharacterBody2D

var move_direction: Vector2
var anim_direction: Vector2
@export var speed : int = 100
@export var camera : Camera2D
var speed_upgrade_multiplier : float = 1.0

func _ready() -> void:
	if camera:
		camera.make_current()
	
	UpgradeManager.upgrades_changed.connect(_update_upgrade_multiplier)
	_update_upgrade_multiplier()

func _update_upgrade_multiplier() -> void:
	if UpgradeManager.has_upgrade("speed"):
		speed_upgrade_multiplier = UpgradeManager.get_upgrade_multiplier("speed")
