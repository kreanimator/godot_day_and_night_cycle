extends Node

## Example script showing how to customize the date/time display
## Attach this to a node in your scene to see different display options

@onready var date_time_ui = get_node("UI/DateTimeUI")

func _ready() -> void:
	await get_tree().process_frame
	_setup_date_time_display()

func _setup_date_time_display() -> void:
	"""Configure the date/time display with different options."""
	if not date_time_ui:
		push_warning("DateTimeUI not found!")
		return
	
	date_time_ui.set_starting_year(2435)
	
	# Example 1: European date format with 24-hour time
	# date_time_ui.set_date_format(date_time_ui.DateFormat.DD_MM_YYYY)
	# date_time_ui.set_time_format(date_time_ui.TimeFormat.HOUR_24)
	
	# Example 2: American date format with 12-hour time
	# date_time_ui.set_date_format(date_time_ui.DateFormat.MM_DD_YYYY)
	# date_time_ui.set_time_format(date_time_ui.TimeFormat.HOUR_12)
	
	# Example 3: Full date with day name and seconds
	date_time_ui.set_date_format(date_time_ui.DateFormat.FULL_DATE)
	date_time_ui.set_time_format(date_time_ui.TimeFormat.HOUR_12)
	date_time_ui.set_show_day_name(true)
	date_time_ui.set_show_seconds(true)
	
	# Example 4: Compact format
	# date_time_ui.set_date_format(date_time_ui.DateFormat.DD_MMM_YYYY)
	# date_time_ui.set_time_format(date_time_ui.TimeFormat.HOUR_12_NO_ZERO)
	# date_time_ui.set_show_day_name(false)
	# date_time_ui.set_show_seconds(false)

func _input(event: InputEvent) -> void:
	"""Handle input to cycle through different display formats."""
	if event.is_action_pressed("debug_1"): 
		_cycle_date_format()
	elif event.is_action_pressed("debug_2"):
		_cycle_time_format()
	elif event.is_action_pressed("debug_3"):
		_cycle_year()

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
