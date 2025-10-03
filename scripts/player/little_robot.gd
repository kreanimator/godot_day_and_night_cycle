extends CharacterBody3D

## Basic Robot Character Controller
## Handles movement, jumping, and animation states
## 
## Required Input Actions:
## - move_forward (W/Up Arrow)
## - move_backward (S/Down Arrow) 
## - move_left (A/Left Arrow)
## - move_right (D/Right Arrow)
## - jump (Space)

# Movement constants
const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Animation state tracking
var is_moving = false
var is_jumping = false
var is_on_ground = true

@onready var animation_player: AnimationPlayer = $AnimationPlayer
var camera_controller: CameraController

func _ready() -> void:
	play_animation("Robot_Idle")
	camera_controller = get_tree().get_first_node_in_group("camera_controller")
	if camera_controller:
		camera_controller.player = self

func _physics_process(delta: float) -> void:
	var was_on_ground = is_on_ground
	is_on_ground = is_on_floor()
	
	if not is_on_ground:
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_ground:
		velocity.y = JUMP_VELOCITY
		is_jumping = true
		play_animation("Robot_Jump")

	var input_dir := Vector2.ZERO
	
	if Input.is_action_pressed("move_forward"):
		input_dir.y -= 1
	if Input.is_action_pressed("move_backward"):
		input_dir.y += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1
	
	if input_dir != Vector2.ZERO:
		var camera_forward = Vector3(0, 0, -1)  
		var camera_right = Vector3(1, 0, 0)  
		
		if camera_controller:
			camera_forward = camera_controller.get_camera_forward()
			camera_right = camera_controller.get_camera_right()
		
		var direction = (camera_forward * -input_dir.y + camera_right * input_dir.x).normalized()
		
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		var target_rotation = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, 10.0 * delta)
		
		is_moving = true
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		is_moving = false

	update_animation_state(was_on_ground)
	move_and_slide()

func update_animation_state(was_on_ground: bool) -> void:
	"""Update animation based on current character state."""
	
	if was_on_ground != is_on_ground and is_on_ground:
		is_jumping = false
	
	if is_jumping:
		return
	
	if is_moving and is_on_ground:
		play_animation("Robot_Running")
	elif is_on_ground:
		play_animation("Robot_Idle")

func play_animation(animation_name: String) -> void:
	"""Play the specified animation if it exists."""
	if animation_player and animation_player.has_animation(animation_name):
		animation_player.play(animation_name)
	else:
		print("Animation not found: ", animation_name)
