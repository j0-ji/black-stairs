extends CharacterBody2D

# --- Exported variables ---
@export var move_speed := 50.0
@export var wander_speed := 25.0
@export var detection_radius := 150.0
@export var attack_range := 25.0
@export var spin_range := 35.0
@export var dash_range := 120.0
@export var ranged_min_distance := 80.0

@export var attack_damage := 1.0
@export var spin_damage := 1.5
@export var dash_damage := 1.5

@export var attack_cooldown := 2.0
@export var spin_cooldown := 4.0
@export var dash_cooldown := 6.0
@export var ranged_cooldown := 3.0

@export var dash_speed := 300.0
@export var dash_duration := 0.25

@export var attack_animation_length := 0.6
@export var spin_animation_length := 0.8
@export var ranged_animation_length := 0.5

@export var max_health := 10.0

# --- Internal state ---
var player: Node2D
var is_attacking := false
var is_dashing := false
var can_attack := true
var can_spin := true
var can_dash := true
var can_ranged := true
var is_dead := false
var enraged := false

var wander_direction := Vector2.ZERO
var wander_timer := 0.0

# --- Nodes ---
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var health: Health = $Health
@onready var melee_hitbox: Area2D = $Hitbox_Stab
@onready var spin_hitbox: Area2D = $Hitbox_Spin
@onready var dash_hitbox: Area2D = $Hitbox_Spin

@onready var projectile_scene: PackedScene = preload("res://Entities/Projectile/Arrow/arrow.tscn")

# --- Timers ---
@onready var atk_timer := Timer.new()
@onready var spin_timer := Timer.new()
@onready var dash_timer := Timer.new()
@onready var ranged_timer := Timer.new()

var hitbox_offset_right := Vector2(0, 0)
var hitbox_offset_left := Vector2(-26, 0)

# --- Ready ---
func _ready():
	player = get_tree().get_first_node_in_group("player")

	health.max_health = max_health
	health.current_health = max_health
	health.died.connect(_on_died)
	health = $Health
	health.health_changed.connect(_on_health_changed)

	_setup_timers()

	melee_hitbox.monitoring = false
	spin_hitbox.monitoring = false
	dash_hitbox.monitoring = false

	melee_hitbox.body_entered.connect(_on_melee_hit)
	spin_hitbox.body_entered.connect(_on_spin_hit)
	dash_hitbox.body_entered.connect(_on_dash_hit)


func _setup_timers():
	add_child(atk_timer)
	add_child(spin_timer)
	add_child(dash_timer)
	add_child(ranged_timer)

	atk_timer.wait_time = attack_cooldown
	atk_timer.one_shot = true
	atk_timer.timeout.connect(func(): can_attack = true)

	spin_timer.wait_time = spin_cooldown
	spin_timer.one_shot = true
	spin_timer.timeout.connect(func(): can_spin = true)

	dash_timer.wait_time = dash_cooldown
	dash_timer.one_shot = true
	dash_timer.timeout.connect(func(): can_dash = true)

	ranged_timer.wait_time = ranged_cooldown
	ranged_timer.one_shot = true
	ranged_timer.timeout.connect(func(): can_ranged = true)


# --- Physics ---
func _physics_process(delta):
	if is_dead or is_attacking or is_dashing:
		move_and_slide()
		return

	if not player:
		return

	var dist = global_position.distance_to(player.global_position)

	if dist <= detection_radius:
		decide_action(dist)
	else:
		wander(delta)

	move_and_slide()


func decide_action(dist):
	# Spin close
	if dist <= spin_range and can_spin:
		start_spin_attack()
		return

	# Normal melee
	if dist <= attack_range and can_attack:
		start_melee_attack()
		return

	# Random dash if player is far enough
	if dist >= dash_range and can_dash and randi() % 3 == 0:
		start_dash_attack()
		return

	# Ranged attack if far away
	if dist >= ranged_min_distance and can_ranged and randi() % 2 == 0:
		start_ranged_attack()
		return

	# Default: move toward player
	move_towards_player()


# --- Movement ---
func move_towards_player():
	var dir = (player.global_position - global_position).normalized()
	velocity = dir * move_speed
	play_move_animation()


func wander(delta):
	wander_timer -= delta
	if wander_timer <= 0:
		wander_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		wander_timer = randf_range(1.0, 3.0)

	velocity = wander_direction * wander_speed

	if wander_direction == Vector2.ZERO:
		play_idle_animation()
	else:
		play_move_animation()


# --- MELEE ATTACK ---
func start_melee_attack():
	is_attacking = true
	can_attack = false
	velocity = Vector2.ZERO

	anim.flip_h = player.global_position.x < global_position.x

	if anim.flip_h:
		melee_hitbox.position = hitbox_offset_left
	else:
		melee_hitbox.position = hitbox_offset_right
	anim.play("attack")

	melee_hitbox.monitoring = true
	await get_tree().create_timer(attack_animation_length).timeout
	melee_hitbox.monitoring = false

	is_attacking = false
	atk_timer.start()
	play_idle_animation()


func _on_melee_hit(body):
	if body.is_in_group("player"):
		body.get_node("Health").take_damage(attack_damage)


# --- SPIN ATTACK ---
func start_spin_attack():
	is_attacking = true
	can_spin = false
	velocity = Vector2.ZERO

	anim.play("spin_attack")
	spin_hitbox.monitoring = true

	await get_tree().create_timer(spin_animation_length).timeout
	spin_hitbox.monitoring = false

	is_attacking = false
	spin_timer.start()
	play_idle_animation()


func _on_spin_hit(body):
	if body.is_in_group("player"):
		body.get_node("Health").take_damage(spin_damage)


# --- DASH ATTACK ---
func start_dash_attack():
	is_dashing = true
	can_dash = false

	anim.play("move")

	var direction = (player.global_position - global_position).normalized()
	velocity = direction * dash_speed
	dash_hitbox.monitoring = true

	await get_tree().create_timer(dash_duration).timeout

	dash_hitbox.monitoring = false
	is_dashing = false
	dash_timer.start()
	play_idle_animation()


func _on_dash_hit(body):
	if body.is_in_group("player"):
		body.get_node("Health").take_damage(dash_damage)


# --- RANGED ATTACK ---
func start_ranged_attack():
	is_attacking = true
	can_ranged = false
	velocity = Vector2.ZERO

	anim.play("ranged_attack")

	await get_tree().create_timer(ranged_animation_length).timeout

	shoot_projectile()

	is_attacking = false
	ranged_timer.start()
	play_idle_animation()


func shoot_projectile():
	var arrow = projectile_scene.instantiate()
	arrow.global_position = global_position
	arrow.direction = (player.global_position - global_position).normalized()
	get_parent().add_child(arrow)


# --- Damage & Enrage ---
func _on_health_changed(current_health: float):
	if is_dead:
		return
	
	if not enraged and current_health <= max_health * 0.5:
		enter_enraged_phase()


func enter_enraged_phase():
	enraged = true
	attack_cooldown *= 0.2
	spin_cooldown *= 0.2
	dash_cooldown *= 0.2
	ranged_cooldown *= 0.3
	move_speed *= 2

	# Update timer wait times
	atk_timer.wait_time = attack_cooldown
	spin_timer.wait_time = spin_cooldown
	dash_timer.wait_time = dash_cooldown
	ranged_timer.wait_time = ranged_cooldown

# --- Animations ---
func play_move_animation():
	anim.play("move")
	anim.flip_h = velocity.x < 0


func play_idle_animation():
	anim.play("idle")


# --- Death ---
func _on_died():
	is_dead = true
	velocity = Vector2.ZERO
	anim.play("death")
	await anim.animation_finished
	queue_free()
