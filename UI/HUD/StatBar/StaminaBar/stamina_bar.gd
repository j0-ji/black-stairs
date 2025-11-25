extends AttributeTrackingProgressBar

func _ready() -> void:
	super._ready()

func register_player(p : Player) -> void:
	super.register_player(p)
	
	_player.stamina.max_stamina_updated.connect(update_max_value)
	_player.stamina.stamina_updated.connect(update_value)
	
	update_max_value(_player.stamina.max_stamina)
	update_value(_player.stamina.current_stamina)

func update_max_value(_new_max_value : float) -> void:
	super.update_max_value(_new_max_value)

func update_value(_new_value : float) -> void:
	super.update_value(_new_value)
