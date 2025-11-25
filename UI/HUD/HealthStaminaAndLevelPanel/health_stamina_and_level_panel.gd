extends PanelContainer

@export var location_label : Label

func _ready() -> void:
	SaveGameManager.global_data.location_updated.connect(update_location_label)
	update_location_label()

func update_location_label() -> void:
	var location = SaveGameManager.global_data.current_location

	if location != "Dungeon":
		location_label.text = location
	else:
		var level = SaveGameManager.global_data.current_dungeon_level
		location_label.text = location + " Level" + str(level)
