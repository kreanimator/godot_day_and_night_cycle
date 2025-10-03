@tool
extends WorldEnvironment

## Day and Night Cycle Controller
## Handles realistic sun and moon positioning, lighting, and seasonal changes
## based on latitude, time of day, and day of year.

# Time and calendar constants
const HOURS_IN_DAY: float = 24.0
const DAYS_IN_YEAR: int = 365

# Astronomical constants
const EARTH_AXIAL_TILT: float = 23.44  # Earth's axial tilt in degrees
const MOON_ORBITAL_INCLINATION: float = 5.14  # Moon's orbital inclination in degrees
const MOON_ORBITAL_PERIOD: float = 29.5  # Moon's orbital period in days
const SUMMER_SOLSTICE_OFFSET: float = 193.0  # Days from summer solstice to year end

# Lighting constants
const HORIZON_SMOOTHSTEP_MIN: float = -0.05
const HORIZON_SMOOTHSTEP_MAX: float = 0.1
const SHADER_TIME_MULTIPLIER: float = 100.0

# Default time scale for optimal gameplay
const DEFAULT_TIME_SCALE: float = 0.01

# Time and location properties
@export_range(0.0, HOURS_IN_DAY, 0.0001) var day_time: float = 12.0:
	set(value):
		day_time = value
		_normalize_day_time()
		_update()

@export_range(-90.0, 90.0, 0.01) var latitude: float = 0.0:
	set(value):
		latitude = value
		_update()

@export_range(1, DAYS_IN_YEAR, 1) var day_of_year: int = 1:
	set(value):
		day_of_year = value
		_update()

# Astronomical properties
@export_range(-180.0, 180.0, 0.01) var planet_axial_tilt: float = EARTH_AXIAL_TILT:
	set(value):
		planet_axial_tilt = value
		_update()

@export_range(-180.0, 180.0, 0.01) var moon_orbital_inclination: float = MOON_ORBITAL_INCLINATION:
	set(value):
		moon_orbital_inclination = value
		_update_moon()

@export_range(0.1, DAYS_IN_YEAR, 0.01) var moon_orbital_period: float = MOON_ORBITAL_PERIOD:
	set(value):
		moon_orbital_period = value
		_update_moon()

# Cloud properties
@export_range(0.0, 1.0, 0.01) var clouds_cutoff: float = 0.3:
	set(value):
		clouds_cutoff = value
		_update_clouds()

@export_range(0.0, 1.0, 0.01) var clouds_weight: float = 0.0:
	set(value):
		clouds_weight = value
		_update_clouds()

# Shader and time properties
@export var use_day_time_for_shader: bool = false:
	set(value):
		use_day_time_for_shader = value
		_update_shader()

@export_range(0.0, 1.0, 0.0001) var time_scale: float = DEFAULT_TIME_SCALE:
	set(value):
		time_scale = value

# Light energy properties (fixed typo: enegry -> energy)
@export_range(0.0, 10.0, 0.01) var sun_base_energy: float = 0.0:
	set(value):
		sun_base_energy = value
		_update_shader()

@export_range(0.0, 10.0, 0.01) var moon_base_energy: float = 0.0:
	set(value):
		moon_base_energy = value
		_update_shader()

# Node references
@onready var sun: DirectionalLight3D = %sun
@onready var moon: DirectionalLight3D = %moon

func _ready() -> void:
	_initialize_sun()
	_initialize_moon()
	_update()

func _process(delta: float) -> void:
	# Only update time in runtime, not in editor
	if not Engine.is_editor_hint():
		day_time += delta * time_scale

# Helper functions
func _normalize_day_time() -> void:
	"""Normalize day_time to be within 0-24 hours and adjust day_of_year accordingly."""
	if day_time < 0.0:
		day_time += HOURS_IN_DAY
		day_of_year -= 1
	elif day_time > HOURS_IN_DAY:
		day_time -= HOURS_IN_DAY
		day_of_year += 1

func _initialize_sun() -> void:
	"""Initialize sun light properties."""
	if is_instance_valid(sun):
		sun.position = Vector3.ZERO
		sun.rotation = Vector3.ZERO
		sun.rotation_order = EULER_ORDER_ZXY
		if sun_base_energy == 0.0:
			sun_base_energy = sun.light_energy

func _initialize_moon() -> void:
	"""Initialize moon light properties."""
	if is_instance_valid(moon):
		moon.position = Vector3.ZERO
		moon.rotation = Vector3.ZERO
		moon.rotation_order = EULER_ORDER_ZXY
		if moon_base_energy == 0.0:
			moon_base_energy = moon.light_energy

func _update() -> void:
	"""Update all celestial objects and environment."""
	_update_sun()
	_update_moon()
	_update_clouds()
	_update_shader()

func _update_sun() -> void:
	"""Update sun position and lighting based on time and season."""
	if not is_instance_valid(sun):
		return
	
	var day_progress: float = day_time / HOURS_IN_DAY
	
	# Calculate sun rotation for day/night cycle
	sun.rotation.x = (day_progress * 2.0 - 0.5) * -PI
	
	# Calculate seasonal variation
	# SUMMER_SOLSTICE_OFFSET gives us 0 for summer solstice and 1 for winter solstice
	var earth_orbit_progress = (float(day_of_year) + SUMMER_SOLSTICE_OFFSET + day_progress) / float(DAYS_IN_YEAR)
	
	# Apply axial tilt for seasonal variation (shorter days in winter, longer in summer)
	sun.rotation.y = deg_to_rad(cos(earth_orbit_progress * PI * 2.0) * planet_axial_tilt)
	sun.rotation.z = deg_to_rad(latitude)
	
	# Calculate light energy based on sun position (disable light below horizon)
	var sun_direction = sun.to_global(Vector3(0.0, 0.0, 1.0)).normalized()
	sun.light_energy = smoothstep(HORIZON_SMOOTHSTEP_MIN, HORIZON_SMOOTHSTEP_MAX, sun_direction.y) * sun_base_energy

func _update_moon() -> void:
	"""Update moon position and lighting based on time and orbital mechanics."""
	if not is_instance_valid(moon):
		return
	
	var day_progress: float = day_time / HOURS_IN_DAY
	
	# Calculate moon's orbital progress
	var moon_orbit_progress: float = (fmod(float(day_of_year), moon_orbital_period) + day_progress) / moon_orbital_period
	
	# Calculate moon rotation
	moon.rotation.x = ((day_progress - moon_orbit_progress) * 2.0 - 1.0) * PI
	
	# Apply orbital inclination and seasonal axial tilt
	var axial_tilt = moon_orbital_inclination
	axial_tilt += planet_axial_tilt * sin((day_progress * 2.0 - 1.0) * PI)
	moon.rotation.y = deg_to_rad(axial_tilt)
	moon.rotation.z = deg_to_rad(latitude)
	
	# Calculate light energy based on moon position (disable light below horizon)
	var moon_direction = moon.to_global(Vector3(0.0, 0.0, 1.0)).normalized()
	moon.light_energy = smoothstep(HORIZON_SMOOTHSTEP_MIN, HORIZON_SMOOTHSTEP_MAX, moon_direction.y) * moon_base_energy

func _update_clouds() -> void:
	"""Update cloud shader parameters."""
	if is_instance_valid(environment):
		environment.sky.sky_material.set_shader_parameter("clouds_cutoff", clouds_cutoff)
		environment.sky.sky_material.set_shader_parameter("clouds_weight", clouds_weight)

func _update_shader() -> void:
	"""Update sky shader with custom time if enabled."""
	if is_instance_valid(environment):
		var shader_time = (day_of_year * HOURS_IN_DAY + day_time) * SHADER_TIME_MULTIPLIER if use_day_time_for_shader else 0.0
		environment.sky.sky_material.set_shader_parameter("overwritten_time", shader_time)
