class_name AttractorComponent
extends Area2D

## Enables attracting objects from the attractable group
##
## For proper use, add a collision shape as a child node to the collectable component.
## Furthermore all attractable things should be of nodetype "CharacterBody2D" (!!!).
## Objects that use this component can attract other objects that fit the collision layer
## mask AND are in the attractable group.
## Adding further collision masks extends who the object can potentially attract.

@export var attraction : float = 150.0

var parent : Node2D
var bodies : Array[Node2D] = []

func _ready() -> void:
	parent = get_parent()

# adds a body to the bodies array after it enters the attraction area,
# so it can be moved towards the node passed in "thing"
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("attractable"):
		bodies.append(body)

# removes a body from the bodies array after it exits the attraction area
func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("attractable") and bodies.has(body):
		bodies.erase(body)

# moves the items that are in the attraction area towards the node passed in "thing"
func _physics_process(_delta: float) -> void:
	for body in bodies.duplicate():
		if not is_instance_valid(body):
			bodies.erase(body)
			continue
		
		var direction = body.global_position.direction_to(parent.global_position)
		
		if body.has_method("apply_attraction_force"):
			body.apply_attraction_force(direction * attraction)
