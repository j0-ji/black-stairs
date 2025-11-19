extends NodeState

@export var character : NonPlayableCharacter
@export var animated_sprite_2d : AnimatedSprite2D
@export var interactable_component : InteractableComponent
@export var idle_state_timer : Timer
@export var min_idle_state_time_interval : float = 3.0
@export var max_idle_state_time_interval : float = 6.0

var _idle_state_timeout : bool = false

func _ready() -> void:
	idle_state_timer.wait_time = randf_range(min_idle_state_time_interval, max_idle_state_time_interval)

func _on_process(_delta: float) -> void:
	pass

func _on_physics_process(_delta: float) -> void:
	pass

func _on_next_transitions() -> void:
	if character.is_focused:
		transition.emit("IdleFocus")
	elif _idle_state_timeout:
		transition.emit("Walk")

func _on_enter() -> void:
	animated_sprite_2d.play("idle")
	_idle_state_timeout = false
	idle_state_timer.wait_time = randf_range(min_idle_state_time_interval, max_idle_state_time_interval)
	idle_state_timer.start()

func _on_exit() -> void:
	animated_sprite_2d.stop()
	idle_state_timer.stop()

func _on_idle_state_timeout() -> void:
	_idle_state_timeout = true
