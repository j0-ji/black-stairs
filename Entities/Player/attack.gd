extends NodeState

@onready var anim = $"../../AnimatedSprite2D"

# Attack configuration
@export var attack_damage := 1
@export var attack_range := 25.0  # Adjust to your sword reach
@export var attack_delay := 0.4  # When the hit occurs, in seconds

var has_attacked := false

func _on_enter():
	has_attacked = false
	anim.flip_h = owner.anim_direction.x < 0
	anim.play("attack")
	
	# Schedule the actual damage hit
	_deal_damage_after_delay(attack_delay)

func _on_physics_process(delta: float) -> void:
	owner.velocity = Vector2.ZERO
	owner.move_and_slide()

func _on_next_transitions() -> void:
	if not anim.is_playing():
		transition.emit("idle")


# --- Damage handling ---
func _deal_damage_after_delay(delay: float) -> void:
	await get_tree().create_timer(delay).timeout
	
	# Only hit once per attack
	if has_attacked:
		return
	has_attacked = true

	var player_pos = owner.global_position

	# Loop over enemies in the scene
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not enemy:
			print("Enemy is null!")
			continue

		# Health node must be a child of the Goblin
		if enemy.has_node("Health"):
			var health_node = enemy.get_node("Health")
			# Only hit goblins within attack_range
			if player_pos.distance_to(enemy.global_position) <= attack_range:
				health_node.take_damage(attack_damage)
				print("Damage done to", enemy.name, "remaining HP:", health_node.current_health)
		else:
			print("No Health node found for", enemy.name)
