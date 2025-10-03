extends Node

## Input Setup Script
## Call this to set up custom input actions for the robot controller

func _ready() -> void:
	_setup_input_actions()

func _setup_input_actions() -> void:
	"""Set up custom input actions for robot movement."""
	
	# Movement actions
	_add_input_action("move_forward", [KEY_W, KEY_UP])
	_add_input_action("move_backward", [KEY_S, KEY_DOWN])
	_add_input_action("move_left", [KEY_A, KEY_LEFT])
	_add_input_action("move_right", [KEY_D, KEY_RIGHT])
	
	# Jump action
	_add_input_action("jump", [KEY_SPACE])
	
	# Debug actions (number keys)
	_add_input_action("debug_1", [KEY_1])
	_add_input_action("debug_2", [KEY_2])
	_add_input_action("debug_3", [KEY_3])

func _add_input_action(action_name: String, keys: Array) -> void:
	"""Add an input action with the specified keys."""
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	
	# Clear existing events for this action
	InputMap.action_erase_events(action_name)
	
	# Add key events
	for key in keys:
		var event = InputEventKey.new()
		event.keycode = key
		InputMap.action_add_event(action_name, event)
	
	print("Added input action: ", action_name, " with keys: ", keys)
