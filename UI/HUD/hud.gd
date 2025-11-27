extends CanvasLayer

@export var shop : PanelContainer
@export var health_stamina_and_location : PanelContainer
var main : Node2D


func _ready() -> void:
	EventBus.shop_open_requested.connect(_on_shop_open_requested)
	EventBus.shop_close_requested.connect(_on_shop_close_requested)

func _on_shop_open_requested() -> void:
	shop.visible = true

func _on_shop_close_requested() -> void:
	shop.visible = false

func register_main(m : Node2D) -> void:
	main = m
	main.update_location.connect(health_stamina_and_location.update_location)
