extends NodeState

@export var character : NonPlayableCharacter
@export var animated_sprite_2d : AnimatedSprite2D
@export var interactable_component : InteractableComponent
@export var idle_focus_state_timer : Timer
@export var min_idle_focus_state_time_interval : float = 3.0
@export var max_idle_focus_state_time_interval : float = 5.0

var _idle_state_timeout : bool = false
var _player : Node2D


func _ready() -> void:
	# idle_focus_state_timer.wait_time = randf_range(min_idle_focus_state_time_interval, max_idle_focus_state_time_interval)
	pass

func _on_process(_delta: float) -> void:
	pass

func _on_physics_process(_delta: float) -> void:
	if character.is_focused and _player != null:
		if _player.global_position.x - character.global_position.x < 0:
			animated_sprite_2d.flip_h = true
		else:
			animated_sprite_2d.flip_h = false

func _on_next_transitions() -> void:
	if !character.is_focused:
		transition.emit("Walk")
	elif _idle_state_timeout:
		transition.emit("Walk")

func _on_enter() -> void:
	animated_sprite_2d.play("idle")
	_idle_state_timeout = false
	# idle_focus_state_timer.wait_time = randf_range(min_idle_focus_state_time_interval, max_idle_focus_state_time_interval)
	# idle_focus_state_timer.start()

func _on_exit() -> void:
	_player = null
	animated_sprite_2d.stop()

func _on_interactable_activated(body : Node2D) -> void:
	_player = body

func _on_interactable_deactivated(_body : Node2D) -> void:
	if character.is_focused:
		character.is_focused = false

func _on_idle_focus_state_timeout() -> void:
	_idle_state_timeout = true
	character.is_focused = false
