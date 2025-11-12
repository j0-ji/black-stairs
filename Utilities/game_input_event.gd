# This class allows retrieving the status of
# current game input events by using static functions.
class_name GameInputEvents

# current animation direction vector (only of player ???)
static var anim_direction: Vector2
# current movement vector (only of player ???)
static var move_direction: Vector2

# returns the current movement direction
static func movement_input() -> Vector2:
	var input_left = Input.is_action_pressed("walk_left")
	var input_right = Input.is_action_pressed("walk_right")
	var input_up = Input.is_action_pressed("walk_up")
	var input_down = Input.is_action_pressed("walk_down")
	
	move_direction = Vector2.ZERO
	
	if input_right && not input_left:
		move_direction.x = 1
	elif input_left && not input_right:
		move_direction.x = -1
		anim_direction = Vector2.LEFT
	if input_up && not input_down:
		move_direction.y = -1
	elif input_down && not input_up:
		move_direction.y = 1
		
	return move_direction

# TRUE when current input is movement.
# FALSE when current input is not movement. 
static func is_movement_input() -> bool:
	if move_direction == Vector2.ZERO:
		return false
	else:
		return true

# Determins the current animation-direction of the Player,
# updates it and returns it.
static func animation_direction() -> Vector2:
	var input_left = Input.is_action_pressed("walk_left")
	var input_right = Input.is_action_pressed("walk_right")
	# var input_up = Input.is_action_pressed("walk_up")
	# var input_down = Input.is_action_pressed("walk_down")
	
	if input_right && not input_left:
		anim_direction = Vector2.RIGHT
	elif input_left && not input_right:
		anim_direction = Vector2.LEFT
	# elif input_up && not input_down:
		# anim_direction = Vector2.UP
	# elif input_down && not input_up:
		# anim_direction = Vector2.DOWN
	
	return anim_direction
