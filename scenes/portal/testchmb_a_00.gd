extends Node3D

var event_00_triggered: bool = false
var sound_timer: float = 0.0
var sound_timings: Dictionary = {
	0.1: "res://assets/sounds/looping_radio_mix.wav",         # 22.00s
	22.0: "res://assets/sounds/GLaDOS/00_part1_entry-1.wav",   # 5.91s
	28.0: "res://assets/sounds/GLaDOS/00_part1_entry-2.wav",   # 4.26s
	32.5: "res://assets/sounds/GLaDOS/00_part1_entry-3.wav",  # 4.89s
	37.5: "res://assets/sounds/GLaDOS/00_part1_entry-4.wav",  # 10.19s
	48.0: "res://assets/sounds/GLaDOS/00_part1_entry-5.wav",  # 5.27s
	53.5: "res://assets/sounds/GLaDOS/00_part1_entry-6.wav",  # 3.01s
	56.5: "res://assets/sounds/GLaDOS/00_part1_entry-7.wav",  # 5.74s
	62.3: "res://assets/sounds/portal_open1.wav"              # 1.89s
}
var timer: Timer


## Called when the node enters the scene tree for the first time.
func _ready() -> void:

	# Disable the mouse pointer and capture the motion
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# Make sure the game is unpaused
	Globals.game_paused = false

	# Put the player in first-person perspective
	$Player.perspective = 1

	# Set camera's position
	$Player/CameraMount/Camera3D.position = Vector3(0.0, 0.0, 0.0)

	# Align visuals with the camera
	$Player/Visuals.rotation = Vector3(0.0, 0.0, $Player/CameraMount.rotation.z)

	# Setup the Timer node
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.1
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

	# Diable the first portal
	toggle_node($RedPortal)

	# Open the first door
	var animation_player = $Door01Wide.get_node("AnimationPlayer")
	animation_player.play("open")


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:

	# Check if the button is triggered
	if len($Button.bodies_in_trigger) > 0  and !$Door01Wide2.open:

		# Play the open animation
		var animation_player = $Door01Wide2.get_node("AnimationPlayer")
		animation_player.play("open")
		$Door01Wide2.open = true

	# Check if the button is not triggered, but still pressed
	if len($Button.bodies_in_trigger) == 0  and $Door01Wide2.open:

		# Play the close animation
		var animation_player = $Door01Wide2.get_node("AnimationPlayer")
		animation_player.play("close")
		$Door01Wide2.open = false


## Timer handler.
func _on_timer_timeout() -> void:

	# Increment timer
	sound_timer += 0.1
 
 	# Check if any sounds should be played at the current time
	for timing in sound_timings:
		if is_equal_approx(sound_timer, timing):
			Globals.play_audio(sound_timings[timing])

			# Get last key
			var last_key = sound_timings.keys()[-1]

			# Stop the timer if the last sound in the dictionary was played
			if timing >= last_key:
				timer.stop()
				sound_timer = 0.0
				# Enable the first portal
				toggle_node($RedPortal)


## [EVENT] Close the door behind the player.
func _on_close_door_body_entered(body: Node3D) -> void:

	# Check is the body is player character
	if body is CharacterBody3D and !event_00_triggered:

		# Flag the event as having been triggered
		event_00_triggered = true

		# Play the close animation
		var animation_player = $Door01Wide.get_node("AnimationPlayer")
		animation_player.play("close")


## Toggles the given node's visibility and its child collision shape.
func toggle_node(node: Node3D) -> void:

	# Make visible
	node.visible = !node.visible

	# Re-enable collision shapes
	for child in node.get_children():
		if child is CollisionShape3D or child is CollisionPolygon3D:
			child.disabled = !child.disabled
