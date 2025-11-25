extends NodeState

@export var player: Player
@export var animated_sprite_2d : AnimatedSprite2D

func _on_process(_delta : float) -> void:
	pass

func _on_physics_process(_delta : float) -> void:
	var move_direction: Vector2 = GameInputEvents.movement_input()
	var anim_direction: Vector2 = GameInputEvents.animation_direction()
	
	animated_sprite_2d.play('walk_right')
	animated_sprite_2d.flip_h = move_direction.x < 0
	
	player.anim_direction = anim_direction
	
	# normalize velocity vector to not move faster diagonally
	if !move_direction.is_normalized():
		move_direction = move_direction.normalized()
		
	player.velocity = move_direction * player.speed.current_stat_value
	player.move_and_slide()

func _on_next_transitions() -> void:
	if !GameInputEvents.is_movement_input():
		transition.emit('Idle')

func _on_enter() -> void:
	pass

func _on_exit() -> void:
	animated_sprite_2d.stop()
