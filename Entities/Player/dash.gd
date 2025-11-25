extends NodeState

# --- Signals ---
signal player_dashed

# --- Exported ---
@export var player: Player
@export var animated_sprite_2d: AnimatedSprite2D
@export var dash_distance := 75.0    
@export var dash_duration := 0.2     

# --- Intern ---
var dash_timer := 0.0
var is_dashing := false
var dash_direction := Vector2.ZERO
var dash_speed := 0.0

func _on_enter() -> void:
	# Stamina verbrauchen
	var used_stamina : bool = player.stamina.use_stamina(1)
	# Falls nicht möglich, da keine stamina mehr -> Dash abbrechen
	if !used_stamina:
		transition.emit("idle")
		return

	is_dashing = true
	dash_timer = dash_duration

	# --- Dash Richtung bestimmen (direkt von Input) ---
	dash_direction = GameInputEvents.movement_input()

	# Falls Spieler stillsteht → Richtung anhand der Animation
	if dash_direction == Vector2.ZERO:
		dash_direction = Vector2(-1, 0) if animated_sprite_2d.flip_h else Vector2(1, 0)

	dash_direction = dash_direction.normalized()

	# --- Dash Geschwindigkeit bestimmen ---
	dash_speed = dash_distance / dash_duration

	# --- Animation ---
	animated_sprite_2d.play("walk_right")
	animated_sprite_2d.flip_h = dash_direction.x < 0
	
	# --- Emit signal that player dashed ---
	player_dashed.emit()

func _on_physics_process(delta: float) -> void:
	if not is_dashing:
		return

	# Dash Bewegung
	player.velocity = dash_direction * dash_speed
	player.move_and_slide()

	# Countdown
	dash_timer -= delta
	if dash_timer <= 0.0:
		is_dashing = false
		transition.emit("idle")

func _on_next_transitions() -> void:
	if not is_dashing:
		transition.emit("idle")
