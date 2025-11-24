extends CharacterBody2D

# --- signal ---
signal died(_global_position : Vector2, _coins : int)

# --- other vars ---
@export var move_speed := 40.0
@export var detection_radius := 150.0
@export var shoot_range := 50.0
@export var shoot_cooldown := 3
@export var attack_delay := 0.2
@export var max_health := 4.0
@export var coins := 3
@export var arrow_scene: PackedScene

var player: Node2D
var can_shoot := true
var is_dead := false
var is_shooting := false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var health: Health = $Health


func _ready():
	health.max_health = max_health
	health.current_health = max_health
	health.died.connect(_on_died)
	player = get_tree().get_first_node_in_group("player")


func _physics_process(delta):
	if is_dead:
		return

	if not player:
		velocity = Vector2.ZERO
		_play_idle()
		move_and_slide()
		return

	var dist = global_position.distance_to(player.global_position)

	# PLAYER OUT OF RANGE
	if dist > detection_radius:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# PLAYER IN RANGE BUT TOO FAR TO SHOOT → MOVE TOWARD PLAYER
	if dist > shoot_range:
		if not is_shooting:
			var direction = (player.global_position - global_position).normalized()
			velocity = direction * move_speed
			_play_move()
		else:
			velocity = Vector2.ZERO

		move_and_slide()
		return

	# PLAYER CLOSE ENOUGH → STOP & SHOOT
	velocity = Vector2.ZERO
	_play_idle()

	if can_shoot and not is_shooting:
		_start_shoot()


func _start_shoot():
	is_shooting = true
	can_shoot = false

	anim.flip_h = player.global_position.x < global_position.x
	anim.play("attack")

	await get_tree().create_timer(attack_delay).timeout

	if is_dead:
		is_shooting = false
		return

	_shoot_arrow()

	await anim.animation_finished

	is_shooting = false

	await get_tree().create_timer(shoot_cooldown).timeout
	can_shoot = true


func _shoot_arrow():
	if not arrow_scene:
		push_warning("Arrow scene not assigned!")
		return

	var direction = (player.global_position - global_position).normalized()

	var arrow = arrow_scene.instantiate()
	arrow.direction = direction

	# Spawn outside the goblin's body
	var spawn_offset = direction * 18
	arrow.global_position = global_position + spawn_offset

	get_parent().add_child(arrow)


func _play_move():
	if not is_shooting:
		anim.play("move_right")
		anim.flip_h = velocity.x < 0


func _play_idle():
	if not is_shooting:
		anim.play("idle_right")
		anim.flip_h = false


func take_damage(amount: float):
	if is_dead:
		return
	health.take_damage(amount)


func _on_died():
	is_dead = true
	velocity = Vector2.ZERO
	is_shooting = false
	can_shoot = false

	var last_flip = anim.flip_h
	anim.play("death")
	anim.flip_h = last_flip

	await anim.animation_finished
	died.emit(global_position, coins)
	queue_free()
