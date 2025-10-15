extends CharacterBody2D

@export var wander_speed := 40.0        # normal wandering speed
@export var burst_speed := 150.0        # speed during lunge
@export var detection_radius := 80.0    # player aggro range
@export var burst_duration := 0.25       # seconds the burst lasts
@export var burst_cooldown := 1.5       # time between bursts

var player: Node2D
var is_aggro := false

# Wandering
var wander_direction := Vector2.ZERO
var wander_timer := 0.0

# Burst
var bursting := false
var burst_timer := 0.0
var cooldown_timer := 0.0

func _ready():
	player = get_tree().get_first_node_in_group("player")

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
	elif cooldown_timer > 0:
		cooldown_timer -= delta

	# Start a burst if player is close and not on cooldown
	if is_aggro and not bursting and cooldown_timer <= 0:
		_start_burst()
	
	if bursting:
		move_and_slide()  
		_play_move_animation()
	elif is_aggro:
		# Player nearby but burst on cooldown → slow approach
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

# --- Burst ---
func _start_burst():
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * burst_speed
	bursting = true
	burst_timer = burst_duration

# --- Animations ---
func _play_move_animation():
	var anim = $AnimatedSprite2D
	anim.play("idle")
	anim.flip_h = velocity.x < 0

func _play_idle_animation():
	var anim = $AnimatedSprite2D
	anim.play("idle")
	anim.flip_h = false
