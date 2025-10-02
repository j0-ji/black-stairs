extends TileMapLayer

# Signals
signal generation_done

# Map gen config
@export var border_width: int = 20 # min width 5
@export var border_base_additive: float = border_width * pow(1.2 * border_width, -2)
@export var border_base_multiplicator: float = 1 + border_base_additive / 0.2
@export var base_map_size: int = 64
var map_width: int = (base_map_size + 2 * border_width)
var map_height: int = (base_map_size + 2 * border_width)
@export var noise_scale: float = 1.0    # Bigger = smoother continents
@export var ground_seed: int = 12345
@export var frequency: float = 0.0125  # 0.0125 Base frequency for FNL
@export var octaves: int = 4
@export var lacunarity: float = 2.1
@export var gain: float = 0.5

# TileSet atlas info
@export var atlas_source_id: int = 1  # <- check in the TileSet inspector
# Map the placeholder tiles (atlas coordinates in the atlas grid)
@export var tile_sand:  Vector2i = Vector2i(0, 0)
@export var tile_grass: Vector2i = Vector2i(1, 0)
@export var tile_dirt:  Vector2i = Vector2i(2, 0)
@export var tile_water: Vector2i = Vector2i(3, 0)
@export var tile_rock:  Vector2i = Vector2i(4, 0)

# Thresholds decide biome by noise value in [-1, 1]
@export var t_water: float = -0.35
@export var t_sand:  float =  -0.25
@export var t_grass: float =  0.4
# >= t_grass becomes rock

var _noise := FastNoiseLite.new()

func _ready() -> void:
	print(border_width)
	print(border_base_additive)
	print(border_base_multiplicator)
	_configure_noise()
	generate_world()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and event.keycode == KEY_R):
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
			var mult = _get_multiplier(x, y)
			_update_cell(x, y, mult)
	update_internals()
	generation_done.emit()

func _pick_tile(n: float) -> Vector2i:
	# n is in [-1, 1]
	if n < t_water:
		return tile_water
	elif n < t_sand:
		return tile_sand
	elif n < t_grass:
		return tile_grass
	else:
		return tile_rock

func _update_cell(x, y, mult):
	var n := _noise.get_noise_2d(float(x) / noise_scale, float(y) / noise_scale)
	var atlas_coords := _pick_tile(n + (border_base_additive * mult))
	set_cell(Vector2i(x, y), atlas_source_id, atlas_coords)

func _get_multiplier(x, y) -> float:
	var mult: float = 0.0
	var mult_y: float = 0.0
	var mult_x: float = 0.0
	
	var mult_variance := 0.98
	
	if y < border_width:
		mult_y = pow(border_base_multiplicator, (border_width - y) / mult_variance)
	elif y > (map_width - (border_width + 1)):
		mult_y = pow(border_base_multiplicator, (border_width - (map_height - (y+1))) / mult_variance )
	
	if x < border_width:
		mult_x = pow(border_base_multiplicator, (border_width - x) / mult_variance)
	elif x > (map_height - (border_width + 1)):
		mult_x = pow(border_base_multiplicator, (border_width - (map_width - (x+1))) / mult_variance)

	if mult_y >= mult_x:
		mult = mult_y
	else:
		mult = mult_x
	
	return mult
