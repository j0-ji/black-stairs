class_name StatComponent
extends Node

var base_stat_value : int
var max_stat_value : int
var current_stat_value : int

@export var is_regeneratable : bool = false
var regen_time : float
var regen_accumulator : float = 0.0

@export var parent : CharacterBody2D

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if is_regeneratable and current_stat_value < max_stat_value:
		regen_accumulator += delta
		if regen_accumulator >= regen_time:
			set_current_stat_value(current_stat_value + 1)
			regen_accumulator = max(regen_accumulator - regen_time, 0)

func set_current_stat_value(new_current_stat_value : int) -> void:
	current_stat_value = new_current_stat_value

func set_max_stat_value(new_max_stat_value : int) -> void:
	max_stat_value = new_max_stat_value

func _set_regen_time(new_regen_time) -> void:
	regen_time = new_regen_time

func _on_upgrade(_upgrade : Upgrade) -> void:
	pass
