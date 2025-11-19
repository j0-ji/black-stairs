extends Area2D

@export var damage := 1.0

func _ready():
	# Connect to the signal to detect when hitbox overlaps something
	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("enemies"):
		if body.has_node("Health"):
			var health_node = body.get_node("Health")
			health_node.take_damage(damage)
			print("Hit enemy:", body.name)
