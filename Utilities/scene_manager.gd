extends Node

var main_scene_path : String = "res://Stages/Main/StageMain.tscn"
var main_scene_root_path : String = "/root/StageMain"
var main_scene_location_root_path : String = "/root/StageMain/GameRoot/LocationRoot"

var location_stages : Dictionary = {
	"Dungeon" : "res://Stages/Dungeon/StageDungeon.tscn",
	"Stairs" : "res://Stages/Stairs/StageStairs.tscn"
}

func load_main_stage_container() -> void:
	if get_tree().root.has_node(main_scene_root_path):
		return 
	
	var node: Node = load(main_scene_path).instantiate()
	
	if node != null:
		get_tree().root.add_child(node)

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
		
		await get_tree().process_frame
		
		location_root.add_child(location_stage)
