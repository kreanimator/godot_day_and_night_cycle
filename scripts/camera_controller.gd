extends Node3D
class_name CameraController



signal set_cam_rotation(cam_rotation: float)

@export var player: CharacterBody3D
@onready var yaw_node: Node3D = %cam_yaw
@onready var pitch_node: Node3D = %cam_pitch
@onready var spring_arm: SpringArm3D = %SpringArm3D
@onready var camera: Camera3D = %Camera3D

var yaw: float = 0.0
var pitch: float = 0.0
var yaw_sensitivity: float = 0.07
var pitch_sensitivity: float = 0.07
var yaw_acceleration: float = 15.0
var pitch_acceleration: float = 15.0
var pitch_max: float = 75.0
var pitch_min: float = -55.0
var tween: Tween
var position_offset: Vector3 = Vector3(0, 1.3, 0)
var position_offset_target: Vector3 = Vector3(0, 1.3, 0)

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)  # Start with visible mouse
	top_level = true
	add_to_group("camera_controller")
	
	await get_tree().process_frame
	_setup_spring_arm()
	
	if not player:
		print("CameraController: No player assigned! Please set the player reference in the scene.")

func _setup_spring_arm() -> void:
	"""Set up the spring arm after nodes are ready."""
	if spring_arm and player:
		spring_arm.add_excluded_object(player.get_rid())

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_mouse_mode()
		return
	
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and event is InputEventMouseMotion:
		yaw += -event.relative.x * yaw_sensitivity
		pitch += event.relative.y * pitch_sensitivity
		pitch = clamp(pitch, pitch_min, pitch_max)

func toggle_mouse_mode() -> void:
	"""Toggle between captured and visible mouse modes."""
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		Input.warp_mouse(Vector2(400, 300))
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	if not player:
		return
	
	position_offset = lerp(position_offset, position_offset_target, 4 * delta)
	var target_position = player.global_position + position_offset
	global_position = lerp(global_position, target_position, 18 * delta)
	
	if yaw_node:
		yaw_node.rotation_degrees.y = lerp(yaw_node.rotation_degrees.y, yaw, yaw_acceleration * delta)
	
	if pitch_node:
		pitch_node.rotation_degrees.x = lerp(pitch_node.rotation_degrees.x, pitch, pitch_acceleration * delta)
	
	if yaw_node:
		set_cam_rotation.emit(yaw_node.rotation.y)

func set_camera_distance(distance: float) -> void:
	"""Set the camera distance from the player."""
	spring_arm.spring_length = distance

func set_camera_height(height: float) -> void:
	"""Set the camera height offset."""
	position_offset_target.y = height

func set_mouse_sensitivity(sensitivity: float) -> void:
	"""Set mouse sensitivity for both yaw and pitch."""
	yaw_sensitivity = sensitivity
	pitch_sensitivity = sensitivity

func get_camera_forward() -> Vector3:
	"""Get the forward direction of the camera (projected onto ground plane)."""
	var forward = -camera.global_transform.basis.z
	forward.y = 0  # Remove Y component for ground movement
	return forward.normalized()

func get_camera_right() -> Vector3:
	"""Get the right direction of the camera (projected onto ground plane)."""
	var right = camera.global_transform.basis.x
	right.y = 0  # Remove Y component for ground movement
	return right.normalized()

func set_fov(value: float) -> void:
	"""Smoothly change camera FOV."""
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(camera, "fov", value, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
