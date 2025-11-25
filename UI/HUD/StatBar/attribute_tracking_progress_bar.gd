class_name AttributeTrackingProgressBar
extends ProgressBar

var _player : Player

func _ready() -> void:
	pass

func register_player(p : Player) -> void:
	_player = p

func update_max_value(_new_max_value : float) -> void:
	max_value = _new_max_value

func update_value(_new_value : float) -> void:
	value = _new_value
