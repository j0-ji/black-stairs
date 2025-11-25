extends Item

var global_target_position : Vector2

func _ready() -> void:
	modulate = Color(0, 0, 0, 0)
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.2)
	tween.tween_property(self, "global_position", global_target_position, 0.4)
