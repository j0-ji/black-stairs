class_name Player
extends CharacterBody2D

const coin_dummy_scene = preload("res://Entities/Items/Coin/CoinDummy/CoinDummy.tscn")

@export var state_machine : NodeStateMachine
@export var health : PlayerHealthStatComponent
@export var stamina : PlayerStaminaStatComponent
@export var speed : PlayerSpeedStatComponent

@export var camera : Camera2D
var move_direction: Vector2
var anim_direction: Vector2

func _ready() -> void:
	if camera:
		camera.make_current()
	
	# --- Connect Signals ---
	WalletManager.got_poorer.connect(_coins_removed)
	
	#  --- Connect self to all other nodes that depend on player --- 
	get_tree().call_group("receive_player_registration", "register_player", self)

func _unhandled_input(event):
	if event.is_action_pressed("attack"):
		state_machine.transition_to("attack")
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			state_machine.transition_to("attack_ranged")
	if Input.is_action_just_pressed("dash"):
		state_machine.transition_to("dash")

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
