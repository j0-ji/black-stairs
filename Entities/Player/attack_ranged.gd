extends NodeState

@onready var anim: AnimatedSprite2D = $"../../AnimatedSprite2D"
@onready var arrow_spawn_point: Node2D = $"../../ArrowSpawnPoint"  # Spawnpunkt vorne am Player

@export var attack_delay := 0.2         # Animation spielt ein bisschen
@export var arrow_scene: PackedScene    # Pfeil-Szene
@export var attack_speed := 400.0       # Pfeilgeschwindigkeit

func _on_enter() -> void:
	# Flipping basierend auf Player-Richtung
	anim.flip_h = owner.anim_direction.x < 0
	arrow_spawn_point.position.x = abs(arrow_spawn_point.position.x) * (1 if not anim.flip_h else -1)
	
	anim.play("attack")
	_shoot_arrow_delayed()

func _on_physics_process(delta: float) -> void:
	owner.velocity = Vector2.ZERO
	owner.move_and_slide()

func _on_next_transitions() -> void:
	if not anim.is_playing():
		transition.emit("idle")

func _shoot_arrow_delayed() -> void:
	await get_tree().create_timer(attack_delay).timeout
	
	if not arrow_scene:
		push_warning("Arrow scene not assigned!")
		return

	var arrow = arrow_scene.instantiate()

	# Richtung zum Mauszeiger
	var target = get_viewport().get_mouse_position()
	var direction = (target - arrow_spawn_point.global_position).normalized()
	arrow.direction = direction
	arrow.speed = attack_speed

	# Pfeil spawn direkt am Spawnpunkt vorne
	arrow.global_position = arrow_spawn_point.global_position

	get_tree().current_scene.add_child(arrow)
