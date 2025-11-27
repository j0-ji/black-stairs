extends Node2D

@export var entrance : Node2D
@export var exit : Node2D
@export var bed : StaticBody2D

const scroll_of_knowledge_path : String = "res://Entities/Items/Scroll/ItemScroll.tscn"

func _ready() -> void:
	if !SaveGameManager.global_data.collected_scroll_of_knowledge:
		var scroll_of_knowledge_resource := load(scroll_of_knowledge_path)
		var scroll_of_knowledge_instance : Item = scroll_of_knowledge_resource.instantiate()
		
		scroll_of_knowledge_instance.global_position = Vector2(360, 475)
		self.add_child(scroll_of_knowledge_instance)
