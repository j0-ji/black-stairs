extends NonPlayableCharacter

@export var hint : PanelContainer

var is_focused : bool = false

func _ready() -> void:
	update_walk_cycles()

func update_walk_cycles() -> void:
	walk_cycles = randi_range(min_walk_cycle, max_walk_cycle)
	
func _unhandled_input(event: InputEvent) -> void:
	if is_focused and event.is_action_pressed("interaction"):
		EventBus.shop_open_requested.emit()

func _on_interactable_activated(body : Node2D) -> void:
	if body.is_in_group("player"):
		hint.visible = true
		is_focused = true

func _on_interactable_deactivated(body : Node2D) -> void:
	if body.is_in_group("player"):
		hint.visible = false
		is_focused = false
