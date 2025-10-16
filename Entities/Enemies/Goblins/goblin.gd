extends CharacterBody2D

@export var move_speed := 50.0
@export var wander_speed := 25.0
@export var detection_radius := 100.0
@export var attack_range := 20.0
@export var attack_cooldown := 2.0
@export var max_health := 5.0  # Goblin HP
@export var attack_damage := 5  # Goblin deals 0.5 to player

var player: Node2D
var is_aggro := false
var is_attacking := false
var can_attack := true

var wander_direction := Vector2.ZERO
var wander_timer := 0.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_timer := Timer.new()
@onready var health: Health = $Health  # Each goblin has its own Health node in the scene

func _ready():
	# Initialize Health
	health.max_health = max_health
	health.current_health = max_health
	health.died.connect(_on_died)
	health.health_changed.connect(_on_health_changed)

	# Player reference
	player = get_tree().get_first_node_in_group("player")

	# Setup attack cooldown timer
	add_child(attack_timer)
	attack_timer.wait_time = attack_cooldown
	attack_timer.one_shot = true
	attack_timer.timeout.connect(_on_attack_cooldown_finished)

func _physics_process(delta):
	if not player or is_attacking:
		move_and_slide()
		return
	
	var distance = global_position.distance_to(player.global_position)
	is_aggro = distance <= detection_radius

	if is_aggro:
		if distance <= attack_range and can_attack:
			_perform_attack()
		else:
			_move_towards_player()
	else:
		_wander(delta)
	
	move_and_slide()

# --- Movement behavior ---
func _move_towards_player():
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * move_speed
	_play_move_animation()

func _wander(delta):
	wander_timer -= delta
	if wander_timer <= 0:
		wander_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		wander_timer = randf_range(1.0, 3.0)
	
	velocity = wander_direction * wander_speed
	
	if wander_direction == Vector2.ZERO:
		_play_idle_animation()
	else:
		_play_move_animation()

# --- Attack behavior ---
func _perform_attack():
	is_attacking = true
	can_attack = false
	velocity = Vector2.ZERO

	anim.flip_h = player.global_position.x < global_position.x
	anim.play("attack")

	# Damage player mid-animation
	await get_tree().create_timer(0.4).timeout
	if player and global_position.distance_to(player.global_position) <= attack_range + 5:
		if player.has_node("Health"):
			player.get_node("Health").take_damage(attack_damage)

	# Start cooldown
	attack_timer.start()

	await anim.animation_finished
	is_attacking = false

func _on_attack_cooldown_finished():
	can_attack = true

# --- Animation helpers ---
func _play_move_animation():
	anim.play("move_right")
	anim.flip_h = velocity.x < 0

func _play_idle_animation():
	anim.play("idle_right")
	anim.flip_h = velocity.x < 0

# --- Health / death handling ---
func take_damage(amount: float):
	if health:
		health.take_damage(amount)

func _on_health_changed(new_hp):
	# Optional: you can flash the sprite or play a hit effect here
	pass

func _on_died():
	# Optional: play death animation
	

	queue_free()  # Remove goblin from scene
