extends Node3D

var event_00_triggered: bool = false


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

 
## [EVENT] Close the door behind the player
func _on_close_door_body_entered(body: Node3D) -> void:

	# Check is the body is player character
	if body is CharacterBody3D and !event_00_triggered:

		# Flag the event as having been triggered
		event_00_triggered = true

		# Play the close animation
		var animation_player = $Door01Wide.get_node("AnimationPlayer")
		animation_player.play("close")
