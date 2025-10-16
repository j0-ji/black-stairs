class_name Player
extends CharacterBody2D

@onready var state_machine = $StateMachine
@onready var health: Health = $Health
var move_direction: Vector2
var anim_direction: Vector2

func _ready():
	# Connect health signals
	health.died.connect(_on_died)
	
func _unhandled_input(event):
	if event.is_action_pressed("attack"):
		state_machine.transition_to("attack")
		
func _on_died():
	await get_tree().create_timer(0.5).timeout  # half-second delay
	get_tree().reload_current_scene()
