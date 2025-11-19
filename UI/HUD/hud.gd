extends CanvasLayer

@export var shop : PanelContainer

func _ready() -> void:
	EventBus.shop_open_requested.connect(_on_shop_open_requested)

func _on_shop_open_requested() -> void:
	shop.visible = true
