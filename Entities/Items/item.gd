class_name Item
extends CharacterBody2D

func apply_attraction_force(attraction_force : Vector2) -> void:
	velocity = attraction_force
	move_and_slide()
