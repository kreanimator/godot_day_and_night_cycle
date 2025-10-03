extends Node

## Debug Controls
## Handles all debug input for time progression and date/time display customization

@onready var day_night_cycle: WorldEnvironment = $"../sky"
@onready var date_time_ui: Control = %DateTimeUI

func _ready() -> void:
	print("DebugControls: Ready - Press 1, 2, 3 for time controls")
	await get_tree().process_frame
	_setup_date_time_display()

func _setup_date_time_display() -> void:
	"""Configure the date/time display with default settings."""
	if not date_time_ui:
		push_warning("DateTimeUI not found!")
		return
	
	date_time_ui.set_starting_year(2435)
	date_time_ui.set_date_format(date_time_ui.DateFormat.FULL_DATE)
	date_time_ui.set_time_format(date_time_ui.TimeFormat.HOUR_12)
	date_time_ui.set_show_day_name(true)
	date_time_ui.set_show_seconds(true)

func _input(event: InputEvent) -> void:
	"""Handle debug input for time progression and display customization."""
	if event.is_action_pressed("debug_1"):
		_add_time(0.25)  # Add 15 minutes
		print("DebugControls: Added 15 minutes")
	
	elif event.is_action_pressed("debug_2"):
		_add_time(1.0)  # Add 1 hour
		print("DebugControls: Added 1 hour")
	
	elif event.is_action_pressed("debug_3"):
		_add_time(24.0)  # Add 1 day
		print("DebugControls: Added 1 day")
	
	elif event.is_action_pressed("debug_4"):
		_cycle_date_format()
		print("DebugControls: Cycled date format")
	
	elif event.is_action_pressed("debug_5"):
		_cycle_time_format()
		print("DebugControls: Cycled time format")
	
	elif event.is_action_pressed("debug_6"):
		_cycle_year()
		print("DebugControls: Cycled year")

func _add_time(hours: float) -> void:
	"""Add time to the day/night cycle system."""
	if day_night_cycle:
		var current_time = day_night_cycle.get("day_time")
		var new_time = fmod(current_time + hours, 24.0)
		day_night_cycle.set("day_time", new_time)
		print("DebugControls: Time changed from ", current_time, " to ", new_time)
		
		# Update day_of_year if we've passed midnight
		if current_time + hours >= 24.0:
			var current_day = day_night_cycle.get("day_of_year")
			var new_day = fmod(current_day + 1, 365)
			day_night_cycle.set("day_of_year", new_day)
			print("DebugControls: Day changed from ", current_day, " to ", new_day)
	else:
		print("DebugControls: Could not find day/night cycle system")

# Additional debug functions for date/time display customization
# You can add more input handlers here as needed

func _cycle_date_format() -> void:
	"""Cycle through different date formats."""
	if not date_time_ui:
		return
	
	var formats = [
		date_time_ui.DateFormat.DD_MM_YYYY,
		date_time_ui.DateFormat.MM_DD_YYYY,
		date_time_ui.DateFormat.YYYY_MM_DD,
		date_time_ui.DateFormat.DD_MMM_YYYY,
		date_time_ui.DateFormat.FULL_DATE
	]
	
	var current_format = date_time_ui.date_format
	var current_index = formats.find(current_format)
	var next_index = (current_index + 1) % formats.size()
	
	date_time_ui.set_date_format(formats[next_index])
	print("Date format changed to: ", date_time_ui.get_formatted_date())

func _cycle_time_format() -> void:
	"""Cycle through different time formats."""
	if not date_time_ui:
		return
	
	var formats = [
		date_time_ui.TimeFormat.HOUR_24,
		date_time_ui.TimeFormat.HOUR_12,
		date_time_ui.TimeFormat.HOUR_12_NO_ZERO
	]
	
	var current_format = date_time_ui.time_format
	var current_index = formats.find(current_format)
	var next_index = (current_index + 1) % formats.size()
	
	date_time_ui.set_time_format(formats[next_index])
	print("Time format changed to: ", date_time_ui.get_formatted_time())

func _cycle_year() -> void:
	"""Cycle through different years for testing."""
	if not date_time_ui:
		return
	
	var years = [2024, 2435, 3000, 2150, 2500]
	var current_year = date_time_ui.starting_year
	var current_index = years.find(current_year)
	var next_index = (current_index + 1) % years.size()
	
	date_time_ui.set_starting_year(years[next_index])
	print("Year changed to: ", years[next_index], " - ", date_time_ui.get_formatted_date())
