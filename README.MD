# Godot Day and Night Cycle System

A comprehensive day and night cycle system for Godot 4 with realistic astronomical calculations, customizable lighting, and date/time display features.

## Features

### Day and Night Cycle
- Realistic sun and moon positioning based on latitude and time
- Seasonal variations with axial tilt simulation
- Configurable time scale for gameplay
- Automatic light energy adjustment based on celestial positions
- Cloud system integration with shader parameters

### Date and Time Display
- Multiple date formats (DD/MM/YYYY, MM/DD/YYYY, YYYY/MM/DD, etc.)
- Multiple time formats (24-hour, 12-hour with AM/PM)
- Configurable starting year for futuristic settings
- Day name display (Monday, Tuesday, etc.)
- Real-time updates synchronized with the cycle system

## Quick Start

### 1. Basic Setup
1. Open the main scene: `scenes/global/main.tscn`
2. The day/night cycle system is already configured on the WorldEnvironment node
3. The date/time display UI is included in the scene

### 2. Running the Scene
- Press F6 or click the play button to run the main scene
- The system will automatically start with the configured settings
- You'll see the date/time display in the bottom-left corner

### 3. Customizing the Cycle System

#### Time and Location Settings
```gdscript
# Access the cycle system
var cycle_system = get_node("sky")  # WorldEnvironment node

# Set time and location
cycle_system.day_time = 14.5  # 2:30 PM
cycle_system.latitude = 40.0  # New York latitude
cycle_system.day_of_year = 150  # Day 150 of the year
```

#### Astronomical Settings
```gdscript
# Configure planetary settings
cycle_system.planet_axial_tilt = 23.44  # Earth's tilt
cycle_system.moon_orbital_period = 29.5  # Moon cycle in days
cycle_system.moon_orbital_inclination = 5.14  # Moon's orbital tilt
```

#### Time Progression
```gdscript
# Set time scale (1.0 = 1 minute per second)
cycle_system.time_scale = 1.0

# Slower progression (0.01 = 1 hour per second)
cycle_system.time_scale = 0.01

# Disable automatic time progression
cycle_system.time_scale = 0.0
```

### 4. Customizing the Date/Time Display

#### Basic Configuration
```gdscript
# Get the UI reference
var date_ui = get_node("UI/DateTimeUI")

# Set date format
date_ui.set_date_format(date_ui.DateFormat.DD_MMM_YYYY)  # 25 Dec 2435
date_ui.set_date_format(date_ui.DateFormat.FULL_DATE)    # 25 December 2435
date_ui.set_date_format(date_ui.DateFormat.DD_MM_YYYY)  # 25/12/2435

# Set time format
date_ui.set_time_format(date_ui.TimeFormat.HOUR_24)      # 14:30
date_ui.set_time_format(date_ui.TimeFormat.HOUR_12)      # 2:30 PM
date_ui.set_time_format(date_ui.TimeFormat.HOUR_12_NO_ZERO)  # 2:30 PM (no leading zero)

# Toggle display options
date_ui.set_show_day_name(true)   # Show "Monday", "Tuesday", etc.
date_ui.set_show_seconds(true)    # Show seconds in time
```

#### Custom Year Settings
```gdscript
# Set starting year for your game world
date_ui.set_starting_year(2435)   # Year 2435
date_ui.set_starting_year(3000)   # Year 3000
date_ui.set_starting_year(2150)   # Year 2150
```

## Available Date Formats

- `DD_MM_YYYY`: 25/12/2435 (European)
- `MM_DD_YYYY`: 12/25/2435 (American)
- `YYYY_MM_DD`: 2435/12/25 (ISO)
- `DD_MMM_YYYY`: 25 Dec 2435 (Short month)
- `FULL_DATE`: 25 December 2435 (Full month name)

## Available Time Formats

- `HOUR_24`: 14:30 or 14:30:45 (24-hour format)
- `HOUR_12`: 2:30 PM or 2:30:45 PM (12-hour with leading zero)
- `HOUR_12_NO_ZERO`: 2:30 PM or 2:30:45 PM (12-hour without leading zero)

## Interactive Controls

### Date/Time Display Controls
Debug time controls for testing the day/night cycle:

- **1**: Add 15 minutes to current time
- **2**: Add 1 hour to current time  
- **3**: Add 1 day (24 hours) to current time

These controls allow you to quickly test different times of day and see how the lighting and date/time display changes.

### Camera Controls
- **Mouse**: Look around (always active)
- **WASD**: Move robot relative to camera
- **Space**: Jump

## Advanced Usage

### Custom Scene Integration
```gdscript
# In your custom scene
extends Node3D

@onready var cycle_system = get_node("WorldEnvironment")
@onready var date_ui = get_node("UI/DateTimeUI")

func _ready():
    # Configure for your game
    cycle_system.latitude = 51.5  # London
    cycle_system.day_time = 9.0   # 9:00 AM
    cycle_system.time_scale = 2.0  # 2 minutes per second
    
    # Set custom year
    date_ui.set_starting_year(2500)
    date_ui.set_date_format(date_ui.DateFormat.FULL_DATE)
```

### Getting Current Date/Time
```gdscript
# Get current date as dictionary
var current_date = date_ui.get_current_date()
print("Year: ", current_date.year)
print("Month: ", current_date.month)
print("Day: ", current_date.day)

# Get formatted strings
print("Date: ", date_ui.get_formatted_date())
print("Time: ", date_ui.get_formatted_time())
```

### Shader Integration
```gdscript
# Enable custom time for sky shader
cycle_system.use_day_time_for_shader = true

# This passes the calculated time to your sky shader
# Access it in shader as: TIME = overwritten_time
```

## File Structure

```
scripts/
├── day&night_cycle.gd          # Main cycle system
├── date_time_display.gd        # Date/time UI controller
└── date_time_example.gd        # Example usage script

scenes/
├── global/
│   └── main.tscn              # Main scene with cycle system
└── ui/
    └── date_time_ui.tscn       # Date/time display UI

resources/
├── materials/
│   └── default_environment.tres
└── shaders/
    └── sky.gdshader           # Sky shader for clouds
```

## Configuration Options

### Day/Night Cycle System
- `day_time`: Current time of day (0-24 hours)
- `latitude`: Geographic latitude (-90 to 90 degrees)
- `day_of_year`: Current day of the year (1-365)
- `planet_axial_tilt`: Axial tilt for seasonal variation
- `moon_orbital_period`: Moon's orbital period in days
- `moon_orbital_inclination`: Moon's orbital inclination
- `time_scale`: Time progression multiplier
- `sun_base_energy`: Base energy for sun light
- `moon_base_energy`: Base energy for moon light

### Date/Time Display
- `date_format`: Date display format
- `time_format`: Time display format
- `starting_year`: Starting year for the game world
- `show_day_name`: Show day of week
- `show_seconds`: Show seconds in time
- `update_interval`: Update frequency in seconds

## Troubleshooting

### Common Issues

1. **Date/Time not updating**: Check that the cycle system is properly connected
2. **Wrong year displayed**: Verify the `starting_year` setting
3. **UI not visible**: Ensure the DateTimeUI node is properly added to the scene
4. **Time not progressing**: Check that `time_scale` is greater than 0

### Debug Information
```gdscript
# Print current cycle system values
print("Day time: ", cycle_system.day_time)
print("Day of year: ", cycle_system.day_of_year)
print("Latitude: ", cycle_system.latitude)

# Print current date/time display
print("Formatted date: ", date_ui.get_formatted_date())
print("Formatted time: ", date_ui.get_formatted_time())
```

## License

This project is open source. See LICENSE file for details.
