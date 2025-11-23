class_name Player
extends CharacterBody2D

@onready var state_machine = $StateMachine
@onready var health: Health = $Health
var move_direction: Vector2
var anim_direction: Vector2
@export var speed : int = 100
@export var camera : Camera2D
var speed_upgrade_multiplier : float = 1.0
var max_stamina := 4
var stamina := 4
@export var stamina_regen_time := 5.0
@onready var stamina_timer := Timer.new()

func _ready() -> void:
	if camera:
		camera.make_current()
	
	UpgradeManager.upgrades_changed.connect(_update_upgrade_multiplier)
	_update_upgrade_multiplier()
	
	stamina_timer.wait_time = 0.1
	stamina_timer.one_shot = false
	add_child(stamina_timer)        
	stamina_timer.start()           
	stamina_timer.timeout.connect(_on_stamina_tick)

	# Connect health signals
	health.died.connect(_on_died)
	
var stamina_regen_accumulator := 0.0

func _on_stamina_tick():
	if stamina < max_stamina:
		stamina_regen_accumulator += stamina_timer.wait_time
		if stamina_regen_accumulator >= stamina_regen_time:
			stamina += 1
			stamina = clamp(stamina, 0, max_stamina)
			stamina_regen_accumulator = 0.0
				
func _unhandled_input(event):
	if event.is_action_pressed("attack"):
		state_machine.transition_to("attack")
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			state_machine.transition_to("attack_ranged")
	if Input.is_action_just_pressed("dash"):
		state_machine.transition_to("dash")		
		
func _update_upgrade_multiplier() -> void:
	if UpgradeManager.has_upgrade("speed"):
		speed_upgrade_multiplier = UpgradeManager.get_upgrade_multiplier("speed")

func _on_died():
	await get_tree().create_timer(0.5).timeout  # half-second delay
	SceneManager.load_location("Village")
