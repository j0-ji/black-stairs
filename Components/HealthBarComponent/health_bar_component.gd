extends ProgressBar

var _parent : CharacterBody2D
var _health : Health

var tween : Tween

func _ready() -> void:
	_parent = get_parent()
	_health = _parent.get_node_or_null("Health")
	
	if _health != null:
		max_value = _health.max_health
		value = _health.current_health
		_health.health_changed.connect(_on_health_changed)
		_health.died.connect(_on_disable)
	else:
		value = max_value
	
	visible = false
	modulate = Color(1, 1, 1, 0)

func _on_health_changed(_current_health : float) -> void:
	if _current_health != max_value and _current_health != 0:
		if not visible:
			_on_enable()
		value = _current_health
	else:
		value = _current_health
		_on_disable()
		

func _on_enable() -> void:
	visible = true
	
	if tween and tween.is_running():
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.15)

func _on_disable() -> void:
	if tween and tween.is_running():
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.15)
	tween.connect("finished", Callable(self, "_on_tween_finished"))

func _on_tween_finished() -> void:
	visible = false
