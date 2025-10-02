extends TileMapLayer

# Random number generator for variations
var rng = RandomNumberGenerator.new()

# Ground layer path - used to read grounds and decide if fauna is allowed on each cell
var ground_layer_path = "../Ground"

# Map gen config
@export var border_width: int = 20 # min width 3
@export var base_map_size: int = 64
var map_width: int = (base_map_size + 2 * border_width)
var map_height: int = (base_map_size + 2 * border_width)
@export var noise_scale: float = 1    # Bigger = smoother continents
@export var ground_seed: int = 12345
@export var frequency: float = 0.7  # 0.0125 Base frequency for FNL
@export var octaves: int = 8
@export var lacunarity: float = 3
@export var gain: float = 0.9

# TileSet atlas info
@export var atlas_source_id: int = 2  # <- check in the TileSet inspector
# Map your placeholder tiles (atlas coordinates in the atlas grid)
var y_atlas_coord_tree: int = 0

# Thresholds decide flora by noise value in [-1, 1]
@export var t_tree: float = 0.2

var _noise := FastNoiseLite.new()

@onready var _ground: TileMapLayer = get_node(ground_layer_path) as TileMapLayer

func _ready() -> void:
	_ground.generation_done.connect(_on_ground_generation_done)
	_configure_noise()
	generate_world()

func _on_ground_generation_done() -> void:
	ground_seed = randi()
	_configure_noise()
	generate_world()

func _configure_noise() -> void:
	_noise.seed = ground_seed
	_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	_noise.frequency = frequency
	_noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	_noise.fractal_octaves = octaves
	_noise.fractal_lacunarity = lacunarity
	_noise.fractal_gain = gain

func generate_world() -> void:
	self.clear()
	for y in map_height:
		for x in map_width:
			var n := _noise.get_noise_2d(float(x) / noise_scale, float(y) / noise_scale)
			
			if n > t_tree:
				var cell := _ground.get_cell_atlas_coords(Vector2i(x, y))
				if cell == Vector2i(1, 0):
					var x_atlas_coord_tree = rng.randi_range(0, 4)
					var atlas_coords := Vector2i(x_atlas_coord_tree, y_atlas_coord_tree)
					set_cell(Vector2i(x, y), atlas_source_id, atlas_coords)
