class_name Player
extends CharacterBody2D

signal stamina_updated
signal max_stamina_updated

signal health_updated
signal max_health_updated

const coin_dummy_scene = preload("res://Entities/Items/Coin/CoinDummy/CoinDummy.tscn")

@onready var state_machine = $StateMachine
@onready var health: Health = $Health
@export var camera : Camera2D
var move_direction: Vector2
var anim_direction: Vector2
@export var speed : int = 100
var speed_upgrade_multiplier : float = 1.0
var max_stamina := 4
var stamina := 4
var base_stamina := 4
@export var stamina_regen_time := 5.0
@onready var stamina_timer := Timer.new()
var base_health_regen = 2
var current_health_regen = base_health_regen

func _ready() -> void:
	if camera:
		camera.make_current()
	
	UpgradeManager.upgrades_changed.connect(_update_upgrade_multiplier)
	WalletManager.got_poorer.connect(_coins_removed)
	_update_upgrade_multiplier("speed")
	_update_upgrade_multiplier("stamina")
	_update_upgrade_multiplier("health")
	_update_upgrade_multiplier("health_regen")
	
	stamina_timer.wait_time = 0.1
	stamina_timer.one_shot = false
	add_child(stamina_timer)        
	stamina_timer.start()           
	stamina_timer.timeout.connect(_on_stamina_tick)

	# Connect health signals
	health.died.connect(_on_died)
	health.health_changed.connect(_on_health_changed)
	
	# Connect self to all other nodes that depend on player
	get_tree().call_group("receive_player_registration", "register_player", self)
	
var stamina_regen_accumulator := 0.0

func _process(_delta : float) -> void:
	health.heal(current_health_regen * _delta)

func _on_stamina_tick():
	if stamina < max_stamina:
		stamina_regen_accumulator += stamina_timer.wait_time
		if stamina_regen_accumulator >= stamina_regen_time:
			stamina += 1
			stamina = clamp(stamina, 0, max_stamina)
			stamina_regen_accumulator = 0.0
			stamina_updated.emit(stamina)
			print("FIRED: stamina_updated")
				
func _unhandled_input(event):
	if event.is_action_pressed("attack"):
		state_machine.transition_to("attack")
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			print("Ranged")
			state_machine.transition_to("attack_ranged")
	if Input.is_action_just_pressed("dash"):
		state_machine.transition_to("dash")		
		
func _update_upgrade_multiplier(upgrade_name : String) -> void:
	if upgrade_name == "speed" and UpgradeManager.has_upgrade("speed"):
		speed_upgrade_multiplier = UpgradeManager.get_upgrade_stat_adapter("speed")
	elif upgrade_name == "stamina" and UpgradeManager.has_upgrade("stamina"):
		max_stamina = base_stamina + UpgradeManager.get_upgrade_stat_adapter("stamina")
		max_stamina_updated.emit(max_stamina)
		print("FIRED: max_stamina_upgraded")
	elif upgrade_name == "health" and UpgradeManager.has_upgrade("health"):
		health.max_health = health.max_health * UpgradeManager.get_upgrade_stat_adapter("health")
		health.current_health = health.max_health
		max_health_updated.emit(health.max_health)
		health_updated.emit(health.current_health)
		print("FIRE: max_health_updated")
	elif upgrade_name == "health_regen" and UpgradeManager.has_upgrade("health_regen"):
		current_health_regen = base_health_regen * UpgradeManager.get_upgrade_stat_adapter("health_regen")
	elif upgrade_name == "damage" and UpgradeManager.has_upgrade("damage"):
		pass
	else:
		push_warning("Invalid Upgrade")

func _on_died():
	await get_tree().create_timer(0.5).timeout  # half-second delay
	SceneManager.load_location("Village")

func _coins_removed() -> void:
	var coin_dummy_instance = coin_dummy_scene.instantiate()
	coin_dummy_instance.global_position = Vector2(global_position.x, global_position.y - 15)
	get_tree().root.add_child(coin_dummy_instance)
	var target_position = Vector2(global_position.x, global_position.y - 25)
	
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(coin_dummy_instance, "position", target_position, 1.0)
	tween.tween_property(coin_dummy_instance, "scale", Vector2(0.5, 0.5), 1.0)
	tween.set_parallel(false)
	tween.tween_callback(coin_dummy_instance.queue_free)


func _on_health_changed(new_value: float) -> void:
	health_updated.emit(new_value)
	print("FIRED: health_updated")

func _on_dash_player_dashed() -> void:
	stamina_updated.emit(stamina)
	print("FIRED: stamina_updated")
