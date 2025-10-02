extends CharacterBody2D

# VARIABLES
const speed = 100
var current_dir = 'down'

# FUNCTIONS
func _init() -> void:
	set_motion_mode(MOTION_MODE_FLOATING)
	
	
func _ready() -> void:
	manage_movement_anim(false)
	
	
func _physics_process(delta: float) -> void:
	player_movement(delta)
	

# function for handling the player movement.
# It checks, which buttons the player is pushing and creates the movement vector
# accordingly. Furthermore it triggers the animation manager depending on the 
# current movement.
func player_movement(delta: float) -> void:
	var input_right = Input.is_action_pressed('ui_right')
	var input_left = Input.is_action_pressed('ui_left')
	var input_up = Input.is_action_pressed('ui_up')
	var input_down = Input.is_action_pressed('ui_down')
	
	velocity.x = 0
	velocity.y = 0
	
	if input_right && not input_left:
		velocity.x = 1
		current_dir = 'right'
		manage_movement_anim(true)
	if input_left && not input_right:
		velocity.x = -1
		current_dir = 'left'
		manage_movement_anim(true)
	if input_up && not input_down:
		velocity.y = -1
		if not input_right && not input_left:
			current_dir = 'up'
			manage_movement_anim(true)
	if input_down && not input_up:
		velocity.y = 1
		if not input_right && not input_left:
			current_dir = 'down'
			manage_movement_anim(true)
	if velocity.x == 0 && velocity.y == 0:
		manage_movement_anim(false)

	velocity = velocity.normalized() * speed
	
	move_and_slide()
	

# function for managing the [movement] animations of the player
# @param movement - indicates if the player is moving/idle
func manage_movement_anim(movement: bool):
	var dir = current_dir
	
	if dir == 'right':
		play_movement_anim('side', movement, false)
	elif dir == 'left':
		play_movement_anim('side', movement, true)
	elif dir == 'up':
		play_movement_anim(dir, movement, false)
	elif dir == 'down':
		play_movement_anim(dir, movement, false)


# function to play a movement animation for the players character
# @param dir - direction, the player is currently facing
# @param movement - indicates if the player is moving/idle
# @param flip - indicates if the sprite should be flipped (left/rigth movement)
func play_movement_anim(dir: String, movement: bool, flip: bool):
	var anim = $AnimatedSprite2D
	anim.flip_h = flip
	
	if movement:
		anim.play('walk_' + dir)
	else:
		anim.play('idle_' + dir)
	
	

	
