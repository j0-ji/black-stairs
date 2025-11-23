class_name GlobalData
extends Resource

signal location_updated

const SAVE_GLOBAL_DATA_FILE_NAME : String = "global_data.tres"

enum spawns {ENTRANCE, BED}

@export var current_dungeon_level = 0
@export var current_location : String = "Village" # use in _read function of level-manager
@export var spawn_point : int = spawns.BED
@export var current_dungeon_seeds : Dictionary = {
	"layer_ground" : randi(),
	"layer_flora" : randi(),
}
@export var upgrades : Dictionary = UpgradeManager._upgrades
@export var wallet : Dictionary = WalletManager.wallet

func set_current_location(location : String) -> void:
	current_location = location
	location_updated.emit()
