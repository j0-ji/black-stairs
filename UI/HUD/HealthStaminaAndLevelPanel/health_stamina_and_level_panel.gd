extends PanelContainer

@export var health_bar : ProgressBar
@export var stamina_bar : ProgressBar
var player : Player

func _ready() -> void:
	pass

func _update_max_health(max_health : float) -> void:
	print("update: MAX HEALTH")
	health_bar.max_value = max_health

func _update_current_health(current_health : float) -> void:
	print("update: HEALTH")
	health_bar.value = current_health
	
func _update_max_stamina(max_stamina : float) -> void:
	print("update: MAX STAMINA")
	stamina_bar.max_value = max_stamina

func _update_current_stamina(current_stamina : float) -> void:
	print("update: STAMINA")
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
