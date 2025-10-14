extends TileMapLayer

# Nodes
@onready var _ground : TileMapLayer = get_node("../Ground")

# Custom signals
signal generation_done

# Random number generator for variations
var rng = RandomNumberGenerator.new()

# From external world_gen_config.gd file
var base_map_size : int = WorldGenConfig.base_map_size
var border_width : int = WorldGenConfig.border_width

# Map gen config
var map_width: int = (base_map_size + 2 * border_width)
var map_height: int = (base_map_size + 2 * border_width)
var noise_scale: float = 1    # Bigger = smoother continents
var frequency: float = 0.7  # 0.0125 Base frequency for FNL
var octaves: int = 8
var lacunarity: float = 3
var gain: float = 0.9

# TileSet atlas info
var atlas_source_id: int = 2  # <- check in the TileSet inspector
# Map your placeholder tiles (atlas coordinates in the atlas grid)
var y_atlas_coord_tree: int = 0
var y_atlas_coord_bush_base: int = 0
var y_atlas_coord_bush_berry: int = 1

# The flora_probabilities dictionary maps each flora type to a probability range [min, max] (from 1 to 100), 
# where the probability ranges should not overlap (!!!)
var flora_probabilities := {
	tree = [31, 100], # 100 - 31 = 69 ; 69 + 1 = 70
	bush_base = [11, 30], # 30 - 11 = 19 ; 19 + 1 = 20
	bush_berries = [1, 10], # 10 - 1 = 9 ; 9 + 1 = 10
}

# Thresholds decide flora by noise value in [-1, 1]
@export var t_flora: float = 0.2

var _noise := FastNoiseLite.new()

func _ready() -> void:
	pass

func _configure_noise() -> void:
	_noise.seed = randi()
	_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	_noise.frequency = frequency
	_noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	_noise.fractal_octaves = octaves
	_noise.fractal_lacunarity = lacunarity
	_noise.fractal_gain = gain

func generate_world() -> void:
	_is_flora_probabilities_ok()
	_configure_noise()
	self.clear()
	for y in map_height:
		for x in map_width:
			var n := _noise.get_noise_2d(float(x) / noise_scale, float(y) / noise_scale)
			if n > t_flora:
				var cell := _ground.get_cell_atlas_coords(Vector2i(x, y))
				if cell == Vector2i(1, 0):
					var flora_type = rng.randi_range(1, 100)
					if flora_type >= flora_probabilities.tree[0] and flora_type <= flora_probabilities.tree[1]:
						var x_atlas_coord_tree = rng.randi_range(0, 4)
						var atlas_coords := Vector2i(x_atlas_coord_tree, y_atlas_coord_tree)
						set_cell(Vector2i(x, y), atlas_source_id, atlas_coords)
					if flora_type >= flora_probabilities.bush_base[0] and flora_type <= flora_probabilities.bush_base[1]:
						var x_atlas_coord_bush_base = rng.randi_range(5, 7)
						var atlas_coords := Vector2i(x_atlas_coord_bush_base, y_atlas_coord_bush_base)
						set_cell(Vector2i(x, y), atlas_source_id, atlas_coords)
					if flora_type >= flora_probabilities.bush_berries[0] and flora_type <= flora_probabilities.bush_berries[1]:
						var x_atlas_coord_bush_berry = rng.randi_range(5, 7)
						var atlas_coords := Vector2i(x_atlas_coord_bush_berry, y_atlas_coord_bush_berry)
						set_cell(Vector2i(x, y), atlas_source_id, atlas_coords)
	
	update_internals()
	generation_done.emit()

func _is_flora_probabilities_ok() -> void:
	var sum : int = 0
	for key in flora_probabilities:
		var diff_min_max = (flora_probabilities[key][1] - flora_probabilities[key][0]) + 1
		sum = sum + diff_min_max
	
	assert(sum == 100, "flora_probabilities not configured correctly. Percantege sums need to add up to 100")
