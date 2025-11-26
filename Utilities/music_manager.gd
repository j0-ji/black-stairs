extends Node

var music_village := preload("res://Assets/Soundtrack/Relax.ogg")
var music_menu := preload("res://Assets/Soundtrack/Innocent.ogg")
var music_dungeon := preload("res://Assets/Soundtrack/Theme.ogg")
var music_boss := preload("res://Assets/Soundtrack/BattleMusic.ogg")
var music_player := AudioStreamPlayer.new()
var menu_player := AudioStreamPlayer.new()
var paused_position: float = 0.0
var is_paused: bool = false

func _ready():
	add_child(music_player)
	add_child(menu_player)
	music_player.bus = "Master"
	menu_player.bus = "Master"
	set_volume(SaveGameManager.settings.current_volume)

func play_preloaded(track: AudioStream):
	music_player.stream = track
	music_player.play()
	is_paused = false

func play_menu_music(track: AudioStream):
	menu_player.stream = track
	menu_player.play()

func pause_music():
	if music_player.playing and not is_paused:
		paused_position = music_player.get_playback_position()
		music_player.stream_paused = true
		is_paused = true

func resume_music():
	if is_paused:
		music_player.stream_paused = false
		music_player.seek(paused_position)
		is_paused = false

func stop_menu_music():
	if menu_player.playing:
		menu_player.stop()		

func set_volume(value: float):
	SaveGameManager.settings.current_volume = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))
