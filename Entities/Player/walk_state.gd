extends NodeState

@export var player: Player
@export var animated_sprite_2d : AnimatedSprite2D
@export var speed: int = 50


func _on_process(_delta : float) -> void:
	pass

func _on_physics_process(_delta : float) -> void:
	var move_direction: Vector2 = GameInputEvents.movement_input()
	var anim_direction: Vector2 = GameInputEvents.animation_direction()
	
	if anim_direction == Vector2.LEFT:
		animated_sprite_2d.play('walk_left')
	elif anim_direction == Vector2.RIGHT:
		animated_sprite_2d.play('walk_right')
	# elif anim_direction == Vector2.UP:
		# animated_sprite_2d.play('walk_back')
	# elif anim_direction == Vector2.DOWN:
		# animated_sprite_2d.play('walk_front')
	
	player.anim_direction = anim_direction
	
	# normalize velocity vector to not move faster diagonally
	if !move_direction.is_normalized():
		move_direction = move_direction.normalized()
		
	player.velocity = move_direction * speed
	player.move_and_slide()

func _on_next_transitions() -> void:
	if !GameInputEvents.is_movement_input():
		transition.emit('Idle')

func _on_enter() -> void:
	pass

func _on_exit() -> void:
	animated_sprite_2d.stop()
