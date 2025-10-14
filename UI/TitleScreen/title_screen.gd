extends Control

const DUNGEON_SCENE := preload("res://scenes/main/dungeon.tscn")

signal new_game

func _ready() -> void:
	pass

func _on_new_game_pressed() -> void:
	var dungeon := DUNGEON_SCENE.instantiate()
	await dungeon.ready
	new_game.emit()
	
	
