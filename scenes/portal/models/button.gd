extends StaticBody3D

var bodies_in_trigger: Array[Node3D] = []

func _on_trigger_body_entered(body: Node3D) -> void:

	# Check if the body is an object or player character
	if body is RigidBody3D or body is CharacterBody3D:

	# Only press the button if no boides preent in the trigger area
		$AnimationPlayer.play("press")

		# Play the "off" sound
		$AudioStreamPlayer.stream =  load("res://assets/sounds/ding_off.wav")
		$AudioStreamPlayer.play()
	
		# Add the body to the tracking array
		bodies_in_trigger.append(body)

func _on_trigger_body_exited(body: Node3D) -> void:

	# Remove the body from the tracking array
	bodies_in_trigger.erase(body)

	# Only release the button if no bodies remain in the trigger area
	if bodies_in_trigger.is_empty():

		# Play the "open" animation
		$AnimationPlayer.play("release")

		# Play the "on" sound
		$AudioStreamPlayer.stream =  load("res://assets/sounds/ding_on.wav")
		$AudioStreamPlayer.play()
