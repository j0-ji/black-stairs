extends CanvasLayer

@export var root_transition_control : Control
@export var dialogue_panel : PanelContainer

@export var dialogue_pre_title : Label
@export var dialogue_title : Label
@export var dialogue_message : Label

var background_fade_transition_time : float = 0.5
var ui_fade_transition_time : float = 0.15

func _ready() -> void:
	EventBus.play_transition.connect(_transition_fade_in)
	

# --- FADE IN ---
## Plays the transition fade in.
func _transition_fade_in(_pre_title : String, _title : String, _message : String) -> void:
	GameManager.game_pause()
	
	if _pre_title.is_empty():
		dialogue_pre_title.visible = false
	else:
		dialogue_pre_title.visible = true
		dialogue_pre_title.text = _pre_title

	dialogue_title.text = _title
	dialogue_message.text = _message
	
	root_transition_control.modulate = Color(1, 1, 1, 0)
	dialogue_panel.modulate = Color(1, 1, 1, 0)
	root_transition_control.visible = true
	
	var tween = create_tween()
	tween.tween_property(root_transition_control, "modulate", Color(1, 1, 1, 1), background_fade_transition_time)
	tween.connect("finished", Callable(self, "_dialogue_fade_in_"))

func _dialogue_fade_in_() -> void:
	dialogue_panel.visible = true
	
	var tween = create_tween()
	tween.tween_property(dialogue_panel, "modulate", Color(1, 1, 1, 1), ui_fade_transition_time)

# --- FADE OUT ---
func _dialogue_fade_out() -> void:
	GameManager.game_unpause()
	var tween = create_tween()
	tween.tween_property(dialogue_panel, "modulate", Color(1, 1, 1, 0), ui_fade_transition_time)
	tween.connect("finished", Callable(self, "_transition_fade_out"))

func _transition_fade_out() -> void:
	dialogue_panel.visible = false
	
	var tween = create_tween()
	tween.tween_property(root_transition_control, "modulate", Color(1, 1, 1, 0), background_fade_transition_time)
	tween.connect("finished", Callable(self, "_transition_fade_out_finish"))

func _transition_fade_out_finish() -> void:
	root_transition_control.visible = false

# --- Button interaction ---
func _on_continue_pressed() -> void:
	_dialogue_fade_out()
