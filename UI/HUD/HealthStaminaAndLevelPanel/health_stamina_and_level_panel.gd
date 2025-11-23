extends PanelContainer

@export var health_bar : ProgressBar
@export var stamina_bar : ProgressBar
@export var location_label : Label
var player : Player

func _ready() -> void:
	SaveGameManager.global_data.location_updated.connect(update_location_label)
	update_location_label()

func _update_max_health(max_health : float) -> void:
	health_bar.max_value = max_health

func _update_current_health(current_health : float) -> void:
	health_bar.value = current_health
	
func _update_max_stamina(max_stamina : float) -> void:
	stamina_bar.max_value = max_stamina

func _update_current_stamina(current_stamina : float) -> void:
	stamina_bar.value = current_stamina

func register_player(p : Player) -> void:
	player = p
	
	player.max_health_updated.connect(_update_max_health)
	player.health_updated.connect(_update_current_health)
	player.max_stamina_updated.connect(_update_max_stamina)
	player.stamina_updated.connect(_update_current_stamina)
	
	_update_max_health(player.health.max_health)
	_update_current_health(player.health.current_health)
	_update_max_stamina(player.max_stamina)
	_update_current_stamina(player.stamina)

func update_location_label() -> void:
	var location = SaveGameManager.global_data.current_location

	if location != "Dungeon":
		location_label.text = location
	else:
		var level = SaveGameManager.global_data.current_dungeon_level
		location_label.text = location + " Level" + str(level)
	
