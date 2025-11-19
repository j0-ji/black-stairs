extends Area2D
class_name Arrow

@export var speed := 200.0
var direction := Vector2.ZERO
@export var damage := 3.0
@export var invincible_time := 0.05  

# Nodes
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

var can_damage := false

func _ready():
	# Stelle sicher, dass die Kollisionsform aktiv ist
	collision.set_deferred("disabled", false)
	# Signal verbinden
	connect("body_entered", Callable(self, "_on_body_entered"))
	# Timer starten, nach dem der Pfeil Schaden machen darf
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
		return  # noch unberührbar

	if body.is_in_group("enemies"):
		print("Arrow hit enemy!")
		if body.has_node("Health"):
			body.get_node("Health").take_damage(damage)
		queue_free()  # Pfeil verschwindet nach Treffer

	if body.is_in_group("player"):
		print("Arrow hit player!")
		if body.has_node("Health"):
			body.get_node("Health").take_damage(damage)
		queue_free()

	elif not body.is_in_group("player"):
		# Wenn er auf eine Wand oder ein anderes Objekt trifft
		print("Arrow hit wall or other object.")
		queue_free()
