extends PanelContainer

@export var label : Label
@export var timer : Timer


func _ready() -> void:
	EventBus.player_message.connect(_on_player_message_event)
	timer.timeout.connect(_on_timer_timeout)
	visible = false

func _on_player_message_event(message : String) -> void:
	label.text = message
	
	modulate = Color(1, 1, 1, 0)
	visible = true
	
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.25)
	tween.connect("finished", Callable(self, "_start_timer"))
	
func _on_timer_timeout() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.25)
	tween.connect("finished", Callable(self, "_disable_visibility"))

func _start_timer() -> void:
	timer.start()

func _disable_visibility() -> void:
	visible = false
