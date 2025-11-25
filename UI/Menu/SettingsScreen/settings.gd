extends Control

func _on_close_pressed() -> void:
	visible = false

func _on_h_slider_value_changed(value: float) -> void:
	MusicManager.set_volume(value)


func _on_visibility_changed() -> void:
	var bus_index = AudioServer.get_bus_index("Master")
	var current_volume_db = AudioServer.get_bus_volume_db(bus_index)
	$SettingsPanel/MarginContainer/VBoxContainer/Volume/MarginContainer/VBoxContainer/HSlider.value = db_to_linear(current_volume_db)
