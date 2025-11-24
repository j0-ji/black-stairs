extends NodeState

# --- Node references ---
@onready var anim: AnimatedSprite2D = $"../../AnimatedSprite2D"
@onready var hitbox: Area2D = $"../../Hitbox"

# --- Attack configuration ---
@export var attack_delay := 0.4         # seconds before hitbox activates
@export var hitbox_duration := 0.2      # how long the hitbox stays active
@export var attack_damage := 1.0        # damage dealt

# --- Hitbox offsets ---
@export var hitbox_offset_right := Vector2(0, 0)
@export var hitbox_offset_left := Vector2(-26, 0)

var has_attacked := false

func _on_enter() -> void:
	has_attacked = false

	# Flip animation based on owner direction
	anim.flip_h = owner.anim_direction.x < 0
	anim.play("attack")

	# Update hitbox position for this attack
	_update_hitbox_position()

	# Start the hitbox activation process
	_activate_hitbox_temporarily()

func _on_physics_process(delta: float) -> void:
	owner.velocity = Vector2.ZERO
	owner.move_and_slide()

func _on_next_transitions() -> void:
	if not anim.is_playing():
		transition.emit("idle")


# --- Activate hitbox briefly ---
func _activate_hitbox_temporarily() -> void:
	await get_tree().create_timer(attack_delay).timeout

	hitbox.set_deferred("monitoring", true)

	# Ensure single connection
	if not hitbox.is_connected("body_entered", Callable(self, "_on_hitbox_body_entered")):
		hitbox.body_entered.connect(Callable(self, "_on_hitbox_body_entered"))

	await get_tree().create_timer(hitbox_duration).timeout
	hitbox.set_deferred("monitoring", false)


# --- Called when hitbox hits a body ---
func _on_hitbox_body_entered(body: Node) -> void:
	hitbox.set_deferred("monitoring", false)  # disable further hits this swing
	if body.is_in_group("enemies") and body.has_node("Health"):
		body.get_node("Health").take_damage(attack_damage)


# --- Update hitbox position for this attack ---
func _update_hitbox_position() -> void:
	if anim.flip_h:
		hitbox.position = hitbox_offset_left
	else:
		hitbox.position = hitbox_offset_right
