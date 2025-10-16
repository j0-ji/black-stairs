extends CharacterBody2D

# --- Movement / burst ---
@export var wander_speed := 40.0        # normal wandering speed
@export var burst_speed := 150.0        # speed during lunge
@export var detection_radius := 80.0    # player aggro range
@export var burst_duration := 0.25      # seconds the burst lasts
@export var burst_cooldown := 1.5       # time between bursts

# --- Health / combat ---
@export var contact_damage := 3       # damage to player on contact
@export var dash_speed := 120.0         # speed when dashing away after hit
@export var dash_duration := 0.3        # duration of dash-away
@export var max_health := 3.0           # slime HP

# --- State variables ---
var player: Node2D
var is_aggro := false

var wander_direction := Vector2.ZERO
var wander_timer := 0.0

var bursting := false
var burst_timer := 0.0
var cooldown_timer := 0.0
var has_hit_player := false

# --- Nodes ---
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var health: Health = $Health

func _ready():
	player = get_tree().get_first_node_in_group("player")

	# Setup health
	health.max_health = max_health
	health.current_health = max_health
	health.died.connect(_on_died)
	health.health_changed.connect(_on_health_changed)

func _physics_process(delta):
	if not player:
		return

	var distance = global_position.distance_to(player.global_position)
	is_aggro = distance <= detection_radius

	# Update timers
	if bursting:
		burst_timer -= delta
		if burst_timer <= 0:
			bursting = false
			cooldown_timer = burst_cooldown
			if has_hit_player:
				has_hit_player = false  # reset after dash-away
	elif cooldown_timer > 0:
		cooldown_timer -= delta

	# Start a burst if player is close and not on cooldown
	if is_aggro and not bursting and cooldown_timer <= 0:
		_start_burst()

	# Check for player contact
	if player and global_position.distance_to(player.global_position) <= 10.0 and not has_hit_player:
		_hit_player()

	# Movement
	if bursting:
		move_and_slide()
		_play_move_animation()
	elif is_aggro:
		# Approach player slowly if not bursting
		velocity = (player.global_position - global_position).normalized() * wander_speed
		move_and_slide()
		_play_move_animation()
	else:
		_wander(delta)

# --- Wandering ---
func _wander(delta):
	wander_timer -= delta
	if wander_timer <= 0:
		wander_direction = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized()
		wander_timer = randf_range(1.0, 2.5)

	velocity = wander_direction * wander_speed
	move_and_slide()

	if wander_direction == Vector2.ZERO:
		_play_idle_animation()
	else:
		_play_move_animation()

# --- Burst / dash ---
func _start_burst():
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * burst_speed
	bursting = true
	burst_timer = burst_duration

func _hit_player():
	has_hit_player = true

	# Deal damage
	if player.has_node("Health"):
		player.get_node("Health").take_damage(contact_damage)

	# Dash away
	var away_direction = (global_position - player.global_position).normalized()
	velocity = away_direction * dash_speed
	bursting = true
	burst_timer = dash_duration

# --- Animations ---
func _play_move_animation():
	anim.play("idle")
	anim.flip_h = velocity.x < 0

func _play_idle_animation():
	anim.play("idle")
	anim.flip_h = false

# --- Health / death ---
func _on_health_changed(new_hp):
	pass  # optional: add hit flash effect here

func _on_died():
	queue_free()  # despawn slime
