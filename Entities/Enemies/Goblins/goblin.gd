extends CharacterBody2D

@export var move_speed := 50.0
@export var wander_speed := 25.0
@export var detection_radius := 100.0

var player: Node2D
var is_aggro := false
var wander_direction := Vector2.ZERO
var wander_timer := 0.0

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if not player:
		return
	
	var distance = global_position.distance_to(player.global_position)
	is_aggro = distance <= detection_radius
	
	if is_aggro:
		_move_towards_player()
	else:
		_wander(delta)
	
	move_and_slide()

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

# --- Animation helpers ---
func _play_move_animation():
	var anim = $AnimatedSprite2D
	anim.play("move_right")
	anim.flip_h = velocity.x < 0

func _play_idle_animation():
	var anim = $AnimatedSprite2D
	anim.play("idle_right")
	anim.flip_h = velocity.x < 0
