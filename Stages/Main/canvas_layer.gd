extends CanvasLayer

@onready var health_bar: ProgressBar = $PlayerHealthBar
@onready var player: Node = get_tree().get_first_node_in_group("player")
@onready var player_health: Health = player.get_node("Health")

func _ready():
	# Initialize health bar
	health_bar.max_value = player_health.max_health
	health_bar.value = player_health.current_health
	
	# Connect signal
	player_health.health_changed.connect(_on_health_changed)

func _on_health_changed(new_hp):
	print("Player health changed.")
	health_bar.value = new_hp
