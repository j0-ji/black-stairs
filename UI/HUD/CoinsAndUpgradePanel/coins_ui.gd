extends PanelContainer

var flashing : bool = false

func _ready() -> void:
	UpgradeManager.not_wealthy_enough.connect(_on_not_wealthy_enough)

func _on_not_wealthy_enough() -> void:
	_flash_red()

func _flash_red():
	if flashing: 
		return  # Prevent overlapping flashes
	flashing = true

	var tween := create_tween()

	tween.tween_property(self, "modulate", Color(1, 0, 0), 0.12)
	tween.tween_property(self, "modulate", Color(1, 1, 1), 0.12)
	
	tween.connect("finished", Callable(self, "_on_flash_finished"))

func _on_flash_finished():
	flashing = false
