class_name EnemySceneDataResource
extends SceneDataResource

@export var current_health : float

func _save_data(node : Node2D) -> void:
	super._save_data(node)
	
	current_health = node.health.current_health

func _load_data(window : Window) -> void:
	super._load_data(window)
	
	if node_path != null:
		var node = window.get_node_or_null(node_path)
		node.health.current_health = current_health
		print("updated health of enemy")
