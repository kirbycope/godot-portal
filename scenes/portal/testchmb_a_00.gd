extends Node3D

var event_00_triggered: bool = false
var sound_timer: float = 0.0
var sound_timings: Dictionary = {
	3.0: "res://assets/sounds/GLaDOS/00_part1_entry-1.wav",  # 5.91s
	9.0: "res://assets/sounds/GLaDOS/00_part1_entry-2.wav",  # 4.26s
	13.5: "res://assets/sounds/GLaDOS/00_part1_entry-3.wav", # 4.89s
	18.5: "res://assets/sounds/GLaDOS/00_part1_entry-4.wav",  # 10.19s
	29.0: "res://assets/sounds/GLaDOS/00_part1_entry-5.wav",  # 5.27s
	34.5: "res://assets/sounds/GLaDOS/00_part1_entry-6.wav",  # 3.01s
	38.0: "res://assets/sounds/GLaDOS/00_part1_entry-7.wav"   # 5.74s
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

			# Stop the timer if the last sound in the dictionary was played
			if timing >= 38.0:
				timer.stop()
				sound_timer = 0.0
				# Place Portal?


## [EVENT] Close the door behind the player.
func _on_close_door_body_entered(body: Node3D) -> void:

	# Check is the body is player character
	if body is CharacterBody3D and !event_00_triggered:

		# Flag the event as having been triggered
		event_00_triggered = true

		# Play the close animation
		var animation_player = $Door01Wide.get_node("AnimationPlayer")
		animation_player.play("close")
