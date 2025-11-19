class_name Player
extends CharacterBody2D

var move_direction: Vector2
var anim_direction: Vector2
@export var speed : int = 100
@export var camera : Camera2D
var speed_upgrade_multiplicator : float = 0.0

func _ready() -> void:
	if camera:
		camera.make_current()
	
	UpgradeManager.upgrades_changed.connect(_update_upgrade_multiplicators)
	_update_upgrade_multiplicators()

func _update_upgrade_multiplicators() -> void:
	if UpgradeManager.has_upgrade("speed"):
		speed_upgrade_multiplicator = UpgradeManager.get_upgrade_multiplicator("speed")
