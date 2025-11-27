extends Node

signal shop_open_requested
signal shop_close_requested
signal player_message(message : String)
signal play_transition(pre_title : String, title : String, message : String)

var transition_screen_path : String = "/root/Main/TransitionScreen"

func play_transition_event(pre_title : String, title : String, message : String) -> void:
	EventBus.play_transition.emit(pre_title, title, message)
	
	if get_tree().root.has_node(transition_screen_path):
		var transition_screen = get_tree().root.get_node(transition_screen_path)
		await get_tree().create_timer(transition_screen.background_fade_transition_time).timeout
	else:
		await get_tree().create_timer(0.5).timeout
