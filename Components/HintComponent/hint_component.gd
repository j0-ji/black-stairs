class_name HintComponent
extends PanelContainer

@export var label : Label
@export var message : String = "placeholder"

func _ready() -> void:
	label.text = message
