extends PanelContainer

@export var label : Label
@export var timer : Timer

var tween : Tween


func _ready() -> void:
	EventBus.player_message.connect(_on_player_message_event)
	timer.timeout.connect(_on_timer_timeout)
	
	visible = false
	modulate = Color(1, 1, 1, 0)

func _on_player_message_event(message : String) -> void:
	label.text = message
	visible = true
	
	if tween and tween.is_running():
		tween.kill()
		
	tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.25)
	tween.connect("finished", Callable(self, "_start_timer"))
	
func _on_timer_timeout() -> void:
	tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.25)
	tween.connect("finished", Callable(self, "_disable_visibility"))

func _start_timer() -> void:
	timer.start()

func _disable_visibility() -> void:
	visible = false
