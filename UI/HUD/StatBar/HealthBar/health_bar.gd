extends AttributeTrackingProgressBar

func _ready() -> void:
	super._ready()

func register_player(p : Player) -> void:
	super.register_player(p)
	
	_player.health.max_health_updated.connect(update_max_value)
	_player.health.health_updated.connect(update_value)
	
	update_max_value(_player.health.max_health)
	update_value(_player.health.current_health)

func update_max_value(_new_max_value : float) -> void:
	super.update_max_value(_new_max_value)

func update_value(_new_value : float) -> void:
	super.update_value(_new_value)
