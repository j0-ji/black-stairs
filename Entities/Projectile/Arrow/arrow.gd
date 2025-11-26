extends Area2D
class_name Arrow

@export var speed := 200.0
var direction := Vector2.ZERO
@export var damage : int = 3

# Nodes
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready():
	# Ensure the collision shape  is active
	collision.set_deferred("disabled", false)
	# connect signal
	connect("body_entered", Callable(self, "_on_body_entered"))

func _physics_process(delta):
	if direction == Vector2.ZERO:
		return
	global_position += direction * speed * delta
	rotation = direction.angle()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemies") or body.is_in_group("player"):
		if body.has_node("Health"):
			body.get_node("Health").take_damage(damage)
		queue_free()  # arrow removed after hit
		return
	else:
		# if the arrow collides with a wall or non enemy object
		queue_free()
		return

func set_collision_layer_and_mask(entity : CharacterBody2D) -> void:
	if entity.is_in_group("enemies"):
		set_collision_mask_value(2, true)
	elif entity.is_in_group("player"):
		set_collision_mask_value(4, true)
	else:
		return
