extends Area2D
class_name Arrow

@export var speed := 200.0
var direction := Vector2.ZERO
@export var damage : int = 3
@export var invincible_time := 0.05  

# Nodes
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

var can_damage := false

func _ready():
	# Ensure the collision shape  is active
	collision.set_deferred("disabled", false)
	# connect signal
	connect("body_entered", Callable(self, "_on_body_entered"))
	# start timer, after which the arrow can actually make damage
	_start_invincibility_timer()

func _physics_process(delta):
	if direction == Vector2.ZERO:
		return
	global_position += direction * speed * delta
	rotation = direction.angle()

func _start_invincibility_timer():
	can_damage = false
	await get_tree().create_timer(invincible_time).timeout
	can_damage = true

func _on_body_entered(body: Node) -> void:
	if not can_damage:
		return  # still invincible

	if body.is_in_group("enemies"):
		if body.has_node("Health"):
			body.get_node("Health").take_damage(damage)
		queue_free()  # arrow removed after hit

	if body.is_in_group("player"):
		if body.has_node("Health"):
			body.get_node("Health").take_damage(damage)
		queue_free()
		return
	elif not body.is_in_group("player"):
		# if the arrow collides with a wall or non enemy object
		queue_free()
		return
