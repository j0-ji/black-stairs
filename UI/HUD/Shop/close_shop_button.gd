extends Button

@export var shop : PanelContainer

func _on_pressed() -> void:
	shop.visible = false
