extends CharacterBody3D
## player_3d.gd

# Player (player_3d.gd)
#├── AudioStreamPlayer3D
#├── CameraMount
#│	└── Camera3D (camera_3d.gd)
#│		└── ChatWindow (chat_window.gd)
#│			└── Message (message.gd)
#│		└── Debug (debug.gd)
#│		└── Emotes (emotes.gd)
#│		└── Pause (pause.gd)
#│		└── Settings (settings.gd)
#├── CollisionShape3D
#├── Controls (controls.gd)
#├── ShapeCast3D
#├── States
#└── Visuals
#	└── AuxScene
#		└── AnimationPlayer

const BONE_NAME_HEAD = "Head"
const BONE_NAME_LEFT_HAND = "LeftHand"
const BONE_NAME_RIGHT_HAND = "RightHand"
const STATES = preload("res://addons/3d_player_controller/states/states.gd")

# Note: `@export` variables are available for editing in the property editor.
@export var current_state: STATES.State = STATES.State.STANDING
@export var enable_chat: bool = true
@export var enable_emotes: bool = true
@export var enable_climbing: bool = true
@export var enable_crouching: bool = true
@export var enable_double_jump: bool = false
@export var enable_flying: bool = false
@export var enable_jumping: bool = true
@export var enable_kicking: bool = true
@export var enable_noclip: bool = false
@export var enable_punching: bool = true
@export var enable_sprinting: bool = true
@export var enable_vibration: bool = false
@export var friction_skateboarding: float = 0.01
@export var force_kicking: float = 2.0
@export var force_kicking_sprinting: float = 3.0
@export var force_punching: float = 1.0
@export var force_punching_sprinting: float = 1.5
@export var force_pushing: float = 1.0
@export var force_pushing_sprinting: float = 2.0
@export var game_paused: bool = false
@export var jump_velocity: float = 4.5
@export var lock_camera: bool = false
@export var lock_movement_x: bool = false
@export var lock_movement_y: bool = false
@export var lock_perspective: bool = false
@export var perspective: int = 0
@export var speed_climbing: float = 0.5
@export var speed_crawling: float = 0.75
@export var speed_current: float = 3.0
@export var speed_flying: float = 5.0
@export var speed_flying_fast: float = 10.0
@export var speed_hanging: float = 0.5
@export var speed_running: float = 3.5
@export var speed_sprinting: float = 5.0
@export var speed_swimming: float = 3.0
@export var speed_walking: float = 1.0
@export var throw_force: float = 3.5

# State machine variables
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var is_aiming: bool = false
var is_animation_locked: bool = false
var is_casting: bool = false
var is_climbing: bool = false
var is_crawling: bool = false
var is_crouching: bool = false
var is_double_jumping: bool = false
var is_driving: bool = false
var is_driving_in
var is_falling: bool = false
var is_firing: bool = false
var is_flying: bool = false
var is_hanging: bool = false
var is_holding: bool = false
var is_holding_fishing_rod: bool = false
var is_holding_rifle: bool = false
var is_holding_tool: bool = false
var is_jumping: bool = false
var is_kicking_left: bool = false
var is_kicking_right: bool = false
var is_punching_left: bool = false
var is_punching_right: bool = false
var is_reeling: bool = false
var is_running: bool = false
var is_shimmying: bool = false
var is_skateboarding: bool = false
var is_skateboarding_on
var is_sprinting: bool = false
var is_standing: bool = false
var is_swimming_in
var is_swimming: bool = false
var is_using: bool = false
var is_walking: bool = false
var virtual_velocity: Vector3 = Vector3.ZERO

# Note: `@onready` variables are set when the scene is loaded.
@onready var animation_player = $Visuals/AuxScene/AnimationPlayer
@onready var audio_player = $AudioStreamPlayer3D
@onready var base_state: BaseState = $States/Base
@onready var camera_mount = $CameraMount
@onready var camera = $CameraMount/Camera3D
@onready var chat_window = $CameraMount/Camera3D/ChatWindow
@onready var collision_shape = $CollisionShape3D
@onready var collision_height = $CollisionShape3D.shape.height
@onready var collision_position = $CollisionShape3D.position
@onready var collision_radius = $CollisionShape3D.shape.radius
@onready var held_item_mount = $Visuals/HeldItemMount
@onready var initial_position = position
@onready var look_at_modifier = $Visuals/AuxScene/GeneralSkeleton/LookAtModifier3D
@onready var player_skeleton = $Visuals/AuxScene/GeneralSkeleton
@onready var raycast_lookat = $CameraMount/Camera3D/RayCast3D
@onready var raycast_jumptarget = $Visuals/RayCast3D_JumpTarget
@onready var raycast_top = $Visuals/RayCast3D_InFrontPlayer_Top
@onready var raycast_high = $Visuals/RayCast3D_InFrontPlayer_High
@onready var raycast_middle = $Visuals/RayCast3D_InFrontPlayer_Middle
@onready var raycast_use = $Visuals/RayCast3D_InFrontPlayer_Use
@onready var raycast_low = $Visuals/RayCast3D_InFrontPlayer_Low
@onready var raycast_below = $Visuals/RayCast3D_BelowPlayer
@onready var menu_pause = $CameraMount/Camera3D/Pause
@onready var menu_settings = $CameraMount/Camera3D/Settings
@onready var shapecast = $ShapeCast3D
@onready var visuals = $Visuals
@onready var visuals_offset = $Visuals.position
@onready var visuals_aux_scene = $Visuals/AuxScene
@onready var visuals_aux_scene_position = $Visuals/AuxScene.position


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Uncomment the next line if using GodotSteam
	#camera.current = is_multiplayer_authority()

	# Make sure the game is unpaused
	game_paused = false

	# Capture the mouse
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# Set the debug canvas layer behind all others
	$Controls.layer = -1
	
	# Display chat if enabled
	chat_window.visible = enable_chat


## Called each physics frame with the time since the last physics frame as argument (delta, in seconds).
func _physics_process(delta) -> void:
	# Uncomment the next line if using GodotSteam
	#if !is_multiplayer_authority(): return

	# Check if the game is not paused
	if !game_paused:
		# Check if no animation is playing
		if !animation_player.is_playing():
			# Flag the animation player no longer locked
			is_animation_locked = false

			# Reset player state
			is_kicking_left = false
			is_kicking_right = false
			is_punching_left = false
			is_punching_right = false

		# Check if the player is not climbing, not driving, and not hanging
		if !is_climbing and !is_driving and !is_hanging:
			# Check if the player is "swimming" or noclip mode is enabled
			if is_swimming or enable_noclip:
				# Ignore the gravity
				velocity.y = 0.0

			# The player must not be "swimming"
			else:
				# Add the gravity
				velocity.y -= gravity * delta

			# Handle player movement
			update_velocity()

		# Check if the animation player is unlocked
		if !is_animation_locked:
			# Move player
			move_player(delta)


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	# Uncomment the next line if using GodotSteam
	#if !is_multiplayer_authority(): return

	# Check if the game is not paused
	if !game_paused:
		# Check if the noclip mode is enabled
		if enable_noclip:
			# [Re]Set player's movement speed
			speed_current = speed_flying_fast
			# [crouch] button _pressed_
			if Input.is_action_pressed("crouch"):
				global_position = global_position - Vector3(0, delta * 10, 0)
			# [jump] button _pressed_
			if Input.is_action_pressed("jump"):
				global_position = global_position + Vector3(0, delta * 10, 0)


## Check if the kick hits anything.
func check_kick_collision() -> void:
	# Check if the RayCast3D is colliding with something
	if raycast_low.is_colliding():
		# Get the object the RayCast is colliding with
		var collider = raycast_low.get_collider()

		# Get the position of the current collision
		var collision_position = raycast_low.get_collision_point()

		# Delay execution
		await get_tree().create_timer(0.5).timeout

		# Flag the animation player no longer locked
		is_animation_locked = false

		# Reset action flag(s)
		is_kicking_left = false
		is_kicking_right = false

		# Apply force to RigidBody3D objects
		if collider is RigidBody3D:
			# Define the force to apply to the collided object
			var force = force_kicking_sprinting if is_sprinting else force_kicking

			# Define the impulse to apply
			var impulse = collision_position - collider.global_position

			# Apply the force to the object
			collider.apply_central_impulse(-impulse * force)

		# Check if the collider is a CharacterBody3D
		if collider is CharacterBody3D:
			# Check if kicking left
			if is_kicking_left:
				# Check if the collider has the appropriate function
				if collider.has_method("animate_hit_low_left"):
					# Play the appropriate hit animation
					collider.call("animate_hit_low_left")

			# Must be kicking right
			else:
				# Check if the collider has the appropriate function
				if collider.has_method("animate_hit_low_right"):
					# Play the appropriate hit animation
					collider.call("animate_hit_low_right")

		# Check if controller vibration is enabled
		if enable_vibration:
			# Vibrate the controller
			Input.start_joy_vibration(0, 0.0, 1.0, 0.1)


## Checks if the thrown punch hits anything.
func check_punch_collision() -> void:
	# Check if the RayCast3D is collining with something
	if raycast_middle.is_colliding():
		# Get the object the RayCast is colliding with
		var collider = raycast_middle.get_collider()

		# Get the position of the current collision
		var collision_position = raycast_middle.get_collision_point()

		# Delay execution
		await get_tree().create_timer(0.3).timeout

		# Flag the animation player no longer locked
		is_animation_locked = false

		# Reset action flag(s)
		is_punching_left = false
		is_punching_right = false

		# Apply force to RigidBody3D objects
		if collider is RigidBody3D:
			# Define the force to apply to the collided force_punching
			var force = force_punching_sprinting if is_sprinting else force_punching

			# Define the impulse to apply
			var impulse = collision_position - collider.global_position

			# Apply the force to the object
			collider.apply_central_impulse(-impulse * force)

		# Check if the collider is a CharacterBody3D
		if collider is CharacterBody3D:
			# Check if punching left
			if is_punching_left:
				# Check if the collider has the appropriate function
				if collider.has_method("animate_hit_high_left"):
					# Play the appropriate hit animation
					collider.call("animate_hit_high_left")

			# Must be punching right
			else:
				# Check if the collider has the appropriate function
				if collider.has_method("animate_hit_high_right"):
					# Play the appropriate hit animation
					collider.call("animate_hit_high_right")

		# Check if controller vibration is enabled
		if enable_vibration:
			# Vibrate the controller
			Input.start_joy_vibration(0, 1.0, 0.0, 0.1)


## Moves the player based on velocity and shapecast collision.
func move_player(delta: float) -> void:
	# Set the shapecast position to the player's potential new position
	shapecast.global_position.x = global_position.x + velocity.x * delta
	shapecast.global_position.z = global_position.z + velocity.z * delta

	# Check if the player is grounded
	if is_on_floor():
		shapecast.target_position.y = -0.5
	else:
		shapecast.target_position.y = 0.55

	# Create a new physics query object used for checking collisions in 3D space
	var query = PhysicsShapeQueryParameters3D.new()

	# Tell the physics query to ignore the current object (self) when checking for collisions
	query.exclude = [self]

	# Set the collision shape to match a "shapecast" object's shape
	query.shape = shapecast.shape

	# Set the position and rotation (transform) to match where the shapecast is in global space
	query.transform = shapecast.global_transform

	# Get the current 3D world, give direct access to the physics engine, and check if the shape intersects with anything (limited to 1 result)
	var result = get_world_3d().direct_space_state.intersect_shape(query, 1)

	# Check if no collisions were detected
	if !result:
		# Force the shapecast to update its state
		shapecast.force_shapecast_update()

	# Check if the shapecast is colliding, the player is moving down (or not at all), no direct collision was found, and the angle of the slope isn't too great
	if shapecast.is_colliding() and velocity.y <= 0.0 and !result and shapecast.get_collision_normal(0).angle_to(Vector3.UP) < floor_max_angle:
		# Set the character's Y position to match the collision point (likely the ground)
		global_position.y = shapecast.get_collision_point(0).y

		# Stop vertical movement by zeroing the Y velocity
		velocity.y = 0.0

	# Handle noclip mode
	if enable_noclip:
		velocity.y = 0.0

	# Moves the body based on velocity.
	move_and_slide()


## Toggles the noclip mode.
func toggle_noclip() -> void:
	enable_noclip = !enable_noclip
	collision_shape.disabled = enable_noclip


## Update the player's velocity based on input and status.
func update_velocity() -> void:
	# Get an input vector by specifying four actions for the positive and negative X and Y axes
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	# Create a normalized 3D direction vector from the 2D input
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Calculate the input magnitude (intensity of the left-analog stick)
	var input_magnitude = input_dir.length()

	# Set the player's movement speed based on the input magnitude
	if speed_current == 0.0 and input_magnitude != 0.0:
		#speed_current = input_magnitude * speed_running 
		speed_current = speed_running # ToDo: Fine tune walking with the left-analog stick

	# Check for directional movement
	if direction:
		# Check if the animation player is unlocked
		if !is_animation_locked:
			# Check if the player is not in "third person" perspective
			if perspective == 0:
				# Update the camera to look in the direction based on player input
				visuals.look_at(position + direction)

			# Check if movement along the x-axis is locked
			if lock_movement_x:
				# Update [virtual] horizontal velocity
				virtual_velocity.x = direction.x * speed_current

			# The x-axis movement not locked
			else:
				# Update horizontal velocity
				velocity.x = direction.x * speed_current

			# Check if movement along the z-axis is locked
			if lock_movement_y:
				# Update vertical velocity
				virtual_velocity.z = direction.z * speed_current

			# The y-axis movement not locked
			else:
				# Update vertical velocity
				velocity.z = direction.z * speed_current

	# No movement detected
	else:
		# Check if the player is skateboarding and grounded
		if is_skateboarding and is_on_floor():
			# Set the friction to the skateboarding friction
			var friction_current = friction_skateboarding

			# [crouch] action _pressed_
			if is_crouching:
				# Slow down the player, more than usual
				friction_current = friction_current * 10

			# Apply gradual deceleration when skating
			velocity.x = move_toward(velocity.x, 0, speed_current * friction_current)
			velocity.z = move_toward(velocity.z, 0, speed_current * friction_current)

		# The player is not skateboarding (on the ground)
		else:
			# Update horizontal velocity
			velocity.x = move_toward(velocity.x, 0, speed_current)

			# Update vertical velocity
			velocity.z = move_toward(velocity.z, 0, speed_current)

			# Update [virtual] velocity
			virtual_velocity = Vector3.ZERO
