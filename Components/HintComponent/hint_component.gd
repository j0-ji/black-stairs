extends ColorRect

@export var label : Label
@export var message : String = "placeholder"

func _ready() -> void:
	label.text = message
