extends Node



signal generate_level

func _ready() -> void:
	pass
	
func new_game() -> void:
	await $LevelMap.ready
	print("now starting new game")
	generate_level.emit()
