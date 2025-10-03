@tool
extends Control

## Date and Time Display UI
## Displays formatted date and time information from the day/night cycle system
## Supports multiple date formats and customizable display options

# Date format options
enum DateFormat {
	DD_MM_YYYY,    # 25/12/2024
	MM_DD_YYYY,    # 12/25/2024
	YYYY_MM_DD,    # 2024/12/25
	DD_MMM_YYYY,   # 25 Dec 2024
	FULL_DATE      # 25 December 2024
}

enum TimeFormat {
	HOUR_24,       # 14:30
	HOUR_12,       # 2:30 PM
	HOUR_12_NO_ZERO # 2:30 PM (no leading zero)
}

# UI References
@onready var date_label: Label = %DateLabel
@onready var time_label: Label = %TimeLabel
@onready var day_name_label: Label = %DayNameLabel

# Display settings
@export var date_format: DateFormat = DateFormat.DD_MMM_YYYY
@export var time_format: TimeFormat = TimeFormat.HOUR_12
@export var show_day_name: bool = true
@export var show_seconds: bool = false
@export var update_interval: float = 0.1  # Update frequency in seconds

# Calendar settings
@export var starting_year: int = 2435

# Reference to the day/night cycle system
@export var day_night_cycle: NodePath
var cycle_system: Node

# Calendar constants
const DAYS_IN_YEAR: int = 365
const DAYS_IN_MONTH: Array[int] = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
const MONTH_NAMES: Array[String] = [
	"January", "February", "March", "April", "May", "June",
	"July", "August", "September", "October", "November", "December"
]
const MONTH_NAMES_SHORT: Array[String] = [
	"Jan", "Feb", "Mar", "Apr", "May", "Jun",
	"Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
]
const DAY_NAMES: Array[String] = [
	"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"
]

# Internal state
var current_date: Dictionary = {}
var update_timer: float = 0.0

func _ready() -> void:
	_setup_ui()
	_connect_to_cycle_system()

func _setup_ui() -> void:
	"""Initialize the UI elements if they don't exist."""
	if not date_label:
		date_label = Label.new()
		date_label.name = "DateLabel"
		add_child(date_label)
	
	if not time_label:
		time_label = Label.new()
		time_label.name = "TimeLabel"
		add_child(time_label)
	
	if not day_name_label:
		day_name_label = Label.new()
		day_name_label.name = "DayNameLabel"
		add_child(day_name_label)
	
	# Set initial visibility
	day_name_label.visible = show_day_name

func _connect_to_cycle_system() -> void:
	"""Connect to the day/night cycle system."""
	if day_night_cycle.is_empty():
		# Try to find the cycle system automatically
		cycle_system = get_tree().get_first_node_in_group("day_night_cycle")
		if not cycle_system:
			# Look for WorldEnvironment with day&night_cycle script
			for node in get_tree().get_nodes_in_group("_world_environment"):
				if node.get_script() and "day" in node.get_script().get_path().to_lower():
					cycle_system = node
					break
	else:
		cycle_system = get_node(day_night_cycle)
	
	if not cycle_system:
		push_warning("DateTimeDisplay: Could not find day/night cycle system!")

func _process(delta: float) -> void:
	"""Update the display at regular intervals."""
	update_timer += delta
	if update_timer >= update_interval:
		_update_display()
		update_timer = 0.0

func _update_display() -> void:
	"""Update the date and time display."""
	if not cycle_system:
		return
	
	# Get current time from cycle system
	var day_of_year = cycle_system.get("day_of_year")
	var day_time = cycle_system.get("day_time")
	
	# Calculate calendar date
	_calculate_calendar_date(day_of_year)
	
	# Update UI elements
	_update_date_display()
	_update_time_display(day_time)
	_update_day_name_display()

func _calculate_calendar_date(day_of_year: int) -> void:
	"""Calculate month, day, and year from day of year."""
	var year = starting_year
	var remaining_days = day_of_year
	
	# Handle year transitions
	while remaining_days > DAYS_IN_YEAR:
		remaining_days -= DAYS_IN_YEAR
		year += 1
	
	while remaining_days <= 0:
		remaining_days += DAYS_IN_YEAR
		year -= 1
	
	# Calculate month and day
	var month = 1
	var day = remaining_days
	
	for i in range(DAYS_IN_MONTH.size()):
		if day <= DAYS_IN_MONTH[i]:
			month = i + 1
			break
		day -= DAYS_IN_MONTH[i]
	
	current_date = {
		"year": year,
		"month": month,
		"day": day,
		"day_of_year": remaining_days
	}

func _update_date_display() -> void:
	"""Update the date label with formatted date."""
	var date_text = _format_date()
	date_label.text = date_text

func _update_time_display(day_time: float) -> void:
	"""Update the time label with formatted time."""
	var time_text = _format_time(day_time)
	time_label.text = time_text

func _update_day_name_display() -> void:
	"""Update the day name label."""
	if not show_day_name:
		return
	
	var day_name = _get_day_name()
	day_name_label.text = day_name

func _format_date() -> String:
	"""Format the date according to the selected format."""
	match date_format:
		DateFormat.DD_MM_YYYY:
			return "%02d/%02d/%04d" % [current_date.day, current_date.month, current_date.year]
		DateFormat.MM_DD_YYYY:
			return "%02d/%02d/%04d" % [current_date.month, current_date.day, current_date.year]
		DateFormat.YYYY_MM_DD:
			return "%04d/%02d/%02d" % [current_date.year, current_date.month, current_date.day]
		DateFormat.DD_MMM_YYYY:
			return "%02d %s %04d" % [current_date.day, MONTH_NAMES_SHORT[current_date.month - 1], current_date.year]
		DateFormat.FULL_DATE:
			return "%02d %s %04d" % [current_date.day, MONTH_NAMES[current_date.month - 1], current_date.year]
		_:
			return "%02d/%02d/%04d" % [current_date.day, current_date.month, current_date.year]

func _format_time(day_time: float) -> String:
	"""Format the time according to the selected format."""
	var hours = int(day_time)
	var minutes = int((day_time - hours) * 60.0)
	var seconds = int(((day_time - hours) * 60.0 - minutes) * 60.0)
	
	match time_format:
		TimeFormat.HOUR_24:
			if show_seconds:
				return "%02d:%02d:%02d" % [hours, minutes, seconds]
			else:
				return "%02d:%02d" % [hours, minutes]
		TimeFormat.HOUR_12:
			var period = "AM" if hours < 12 else "PM"
			var display_hour = hours % 12
			if display_hour == 0:
				display_hour = 12
			
			if show_seconds:
				return "%02d:%02d:%02d %s" % [display_hour, minutes, seconds, period]
			else:
				return "%02d:%02d %s" % [display_hour, minutes, period]
		TimeFormat.HOUR_12_NO_ZERO:
			var period = "AM" if hours < 12 else "PM"
			var display_hour = hours % 12
			if display_hour == 0:
				display_hour = 12
			
			if show_seconds:
				return "%d:%02d:%02d %s" % [display_hour, minutes, seconds, period]
			else:
				return "%d:%02d %s" % [display_hour, minutes, period]
		_:
			return "%02d:%02d" % [hours, minutes]

func _get_day_name() -> String:
	"""Calculate the day of the week name."""
	# Simple day calculation (this could be made more accurate)
	var day_of_week = (current_date.day_of_year - 1) % 7
	return DAY_NAMES[day_of_week]

# Public API functions
func set_date_format(format: DateFormat) -> void:
	"""Change the date format."""
	date_format = format

func set_time_format(format: TimeFormat) -> void:
	"""Change the time format."""
	time_format = format

func set_show_day_name(show: bool) -> void:
	"""Toggle day name display."""
	show_day_name = show
	day_name_label.visible = show

func set_show_seconds(show: bool) -> void:
	"""Toggle seconds display."""
	show_seconds = show

func set_update_interval(interval: float) -> void:
	"""Set the update interval in seconds."""
	update_interval = interval

func set_starting_year(year: int) -> void:
	"""Set the starting year for the game world."""
	starting_year = year

func get_current_date() -> Dictionary:
	"""Get the current calculated date as a dictionary."""
	return current_date.duplicate()

func get_formatted_date() -> String:
	"""Get the current formatted date string."""
	return _format_date()

func get_formatted_time() -> String:
	"""Get the current formatted time string."""
	if cycle_system:
		return _format_time(cycle_system.get("day_time"))
	return "00:00"
