extends Node

signal update_player_position

const PLAYER = preload("res://Entities/Player/player.tscn")

var main_scene_path : String = "res://Stages/Main/Main.tscn"
var main_scene_root_path : String = "Main"
var main_scene_game_root_root_path : String = "/root/Main/GameRoot"
var main_scene_location_root_path : String = "/root/Main/GameRoot/LocationRoot"

var location_stages : Dictionary = {
	"Dungeon" : "res://Stages/Dungeon/StageDungeon.tscn",
	"Stairs" : "res://Stages/Stairs/StageStairs.tscn",
	"Village" : "res://Stages/Village/Village.tscn"
}

func load_main_stage_container(with_player : bool = false, with_initial_location : bool = false) -> void:
	if get_tree().root.has_node(main_scene_root_path):
		return 
	
	var node: Node = load(main_scene_path).instantiate()
	
	if node != null:
		node.with_initial_location = with_initial_location
		get_tree().root.add_child(node)
	
	if with_player:
		var game_root = get_node(main_scene_game_root_root_path)
		var player = PLAYER.instantiate()
		
		if game_root != null:
			game_root.add_child(player)
			await get_tree().process_frame
			update_player_position.emit()

func load_location(location: String) -> void:
	var scene_path : String = location_stages.get(location)
	
	if scene_path == null:
		push_error("Invalid location")
		return
	
	var location_stage: Node = load(scene_path).instantiate()
	var location_root: Node = get_node(main_scene_location_root_path)
	
	if location_root != null:
		var nodes = location_root.get_children()
		
		if !nodes.is_empty():
			for node: Node in nodes:
				node.queue_free()
		
		location_root.add_child(location_stage)
		await get_tree().process_frame
	
