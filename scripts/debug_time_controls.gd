extends Node

## Debug Time Controls
## Handles debug input for time progression in the day/night cycle system

@onready var day_night_cycle: WorldEnvironment = $"../sky"

func _ready() -> void:
	print("DebugTimeControls: Ready - Press 1, 2, 3 for time controls")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_1"):
		_add_time(0.25)
		print("DebugTimeControls: Added 15 minutes")
	
	elif event.is_action_pressed("debug_2"):
		_add_time(1.0)
		print("DebugTimeControls: Added 1 hour")
	
	elif event.is_action_pressed("debug_3"):
		_add_time(24.0)
		print("DebugTimeControls: Added 1 day")

func _add_time(hours: float) -> void:
	"""Add time to the day/night cycle system."""
	if day_night_cycle:
		var current_time = day_night_cycle.get("day_time")
		var new_time = fmod(current_time + hours, 24.0)
		day_night_cycle.set("day_time", new_time)
		print("DebugTimeControls: Time changed from ", current_time, " to ", new_time)
		
		if current_time + hours >= 24.0:
			var current_day = day_night_cycle.get("day_of_year")
			var new_day = fmod(current_day + 1, 365)
			day_night_cycle.set("day_of_year", new_day)
			print("DebugTimeControls: Day changed from ", current_day, " to ", new_day)
	else:
		print("DebugTimeControls: Could not find day/night cycle system")
