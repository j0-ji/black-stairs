extends CanvasLayer

@export var shop : PanelContainer
@export var health_stamina_and_locaiton : PanelContainer
var main : Node2D


func _ready() -> void:
	EventBus.shop_open_requested.connect(_on_shop_open_requested)

func _on_shop_open_requested() -> void:
	shop.visible = true

func register_main(m : Node2D) -> void:
	main = m
	main.update_location.connect(health_stamina_and_locaiton.update_location)
