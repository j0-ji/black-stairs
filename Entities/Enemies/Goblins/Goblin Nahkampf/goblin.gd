extends CharacterBody2D

# --- Exported ---
@export var move_speed := 50.0
@export var wander_speed := 25.0
@export var detection_radius := 100.0
@export var attack_range := 20.0
@export var attack_cooldown := 2.0
@export var attack_damage := 0.5
@export var max_health := 5.0
@export var attack_animation_length := 0.6

# --- State ---
var player: Node2D
var is_aggro := false
var is_attacking := false
var can_attack := true
var is_dead := false
var wander_direction := Vector2.ZERO
var wander_timer := 0.0

# --- Node references ---
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var health: Health = $Health
@onready var hitbox: Area2D = $Hitbox
@onready var attack_timer := Timer.new()

# --- Hitbox offsets ---
var hitbox_offset_right := Vector2(0, 0)
var hitbox_offset_left := Vector2(-26, 0)

# --- Ready ---
func _ready():
	health.max_health = max_health
	health.current_health = max_health
	health.died.connect(_on_died)

	player = get_tree().get_first_node_in_group("player")

	add_child(attack_timer)
	attack_timer.wait_time = attack_cooldown
	attack_timer.one_shot = true
	attack_timer.timeout.connect(_on_attack_cooldown_finished)

	hitbox.monitoring = false
	if not hitbox.is_connected("body_entered", Callable(self, "_on_hitbox_body_entered")):
		hitbox.connect("body_entered", Callable(self, "_on_hitbox_body_entered"))

# --- Physics ---
func _physics_process(delta):
	if is_dead:
		return

	if not player or is_attacking:
		move_and_slide()
		return

	var distance = global_position.distance_to(player.global_position)
	is_aggro = distance <= detection_radius

	if is_aggro:
		if distance <= attack_range and can_attack:
			_start_attack()
		else:
			_move_towards_player()
	else:
		_wander(delta)

	move_and_slide()
	_update_hitbox_position()

# --- Movement ---
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

# --- Attack ---
func _start_attack():
	if is_dead:
		return

	is_attacking = true
	can_attack = false
	velocity = Vector2.ZERO

	anim.flip_h = player.global_position.x < global_position.x

	if anim.flip_h:
		hitbox.position = hitbox_offset_left
	else:
		hitbox.position = hitbox_offset_right

	anim.play("attack")
	hitbox.monitoring = true
	await get_tree().create_timer(attack_animation_length).timeout
	hitbox.monitoring = false

	is_attacking = false
	_play_idle_animation()
	attack_timer.start()

func _on_attack_cooldown_finished():
	can_attack = true

# --- Hitbox follow ---
func _update_hitbox_position():
	if anim.flip_h:
		hitbox.position = hitbox_offset_left
	else:
		hitbox.position = hitbox_offset_right

# --- Hitbox collision ---
func _on_hitbox_body_entered(body: Node):
	if is_dead:
		return

	if body.is_in_group("player") and body.has_node("Health"):
		body.get_node("Health").take_damage(attack_damage)

# --- Animation helpers ---
func _play_move_animation():
	anim.play("move_right")
	anim.flip_h = velocity.x < 0

func _play_idle_animation():
	anim.play("idle_right")
	anim.flip_h = false

# --- Health / death ---
func take_damage(amount: float):
	if is_dead:
		return
	var shader_mat = anim.material as ShaderMaterial
	if shader_mat:
		shader_mat.set_shader_parameter("flash_amount", 1.0)
		await get_tree().create_timer(0.1).timeout
		shader_mat.set_shader_parameter("flash_amount", 0.0)
	health.take_damage(amount)

func _on_died():
	is_dead = true
	is_attacking = false
	can_attack = false
	velocity = Vector2.ZERO

	hitbox.monitoring = false

	var last_flip = anim.flip_h
	anim.play("death")
	anim.flip_h = last_flip

	await anim.animation_finished
	queue_free()
