class_name NodeStateMachine
extends Node

@export var initial_node_state: NodeState

var node_states: Dictionary = {}
var current_node_state: NodeState
var current_node_state_name: String

# A child is the child-element in the scene.
# This script is atatched to a StateMachine Node.
# The StateMachine Node has child nodes of type NodeState.
# The child nodes are gathered on initialization and saved in
# the node_states array. 
func _ready() -> void:
	for child in get_children():
		if child is NodeState:
			node_states[child.name.to_lower()] = child
			child.transition.connect(transition_to)
	
	if initial_node_state:
		initial_node_state._on_enter()
		current_node_state = initial_node_state

# Calls the process funtion of the current node state.
func _process(delta: float) -> void:
	if current_node_state:
		current_node_state._on_process(delta)

# Runs the physics process of the current state.
# Then checks if the state has changed. If so,
# transitions to another state.
func _physics_process(delta: float) -> void:
	if current_node_state:
		current_node_state._on_physics_process(delta)
		current_node_state._on_next_transitions()

# Function to transition from one state to another.
func transition_to(node_state_name: String) -> void:
	if node_state_name == current_node_state.name.to_lower():
		return
	
	var new_node_state = node_states.get(node_state_name.to_lower())
	
	if !new_node_state:
		return
	
	if current_node_state:
		current_node_state._on_exit()
	
	new_node_state._on_enter()
	
	current_node_state = new_node_state
	current_node_state_name = current_node_state.name.to_lower()
	print('Current State: ', current_node_state_name)
