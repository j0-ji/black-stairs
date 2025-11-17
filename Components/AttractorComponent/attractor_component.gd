class_name AttractorComponent
extends Area2D

@export var thing : Node2D
@export var attraction : float = 150.0

var bodies : Array[Node2D] = []

func _on_body_entered(body: Node2D) -> void:
	print("entered attractor component")
	if body.is_in_group("attractable"):
		print("found attractable")
		bodies.append(body)

func _on_body_exited(body: Node2D) -> void:
	print("exited attractor component")
	if body.is_in_group("attractable") and bodies.has(body):
		bodies.erase(body)

func _physics_process(_delta: float) -> void:
	for body in bodies:
		var direction = body.global_position.direction_to(thing.global_position)
		body.velocity = direction * attraction
		body.move_and_slide()
