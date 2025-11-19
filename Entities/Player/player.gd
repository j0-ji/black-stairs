class_name Player
extends CharacterBody2D

@onready var state_machine = $StateMachine
@onready var health: Health = $Health
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

	# Connect health signals
	health.died.connect(_on_died)
	
func _unhandled_input(event):
	if event.is_action_pressed("attack"):
		state_machine.transition_to("attack")
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			print("Ranged")
			state_machine.transition_to("attack_ranged")
		
func _update_upgrade_multiplier() -> void:
	if UpgradeManager.has_upgrade("speed"):
		speed_upgrade_multiplier = UpgradeManager.get_upgrade_multiplier("speed")

func _on_died():
	await get_tree().create_timer(0.5).timeout  # half-second delay
	SceneManager.load_location("Village")
