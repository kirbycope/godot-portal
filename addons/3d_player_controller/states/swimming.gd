extends BaseState

var node_name = "Swimming"


## Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	# Uncomment the next line if using GodotSteam
	#if !is_multiplayer_authority(): return

	# Check if the game is not paused
	if !player.game_paused:

		# [crouch] button just _pressed_
		if Input.is_action_pressed("crouch"):

			# Decrement the player's vertical position
			player.position.y -= 0.01

		# [jump] button just _pressed_
		if Input.is_action_pressed("jump"):

			var water_top = player.swimming_in.get_parent().position.y + (player.swimming_in.get_child(0).shape.size.y / 2)
			var new_position = player.position.y + 0.01
			var player_top = new_position + player.collision_height/2

			if player_top <= water_top:
				player.position.y = new_position

	# Check if the player is not "swimming"
	if !player.is_swimming:

		# Start "standing"
		transition(node_name, "Standing")

	# Check if the player is "swimming"
	if player.is_swimming:

		# Play the animation
		play_animation()


## Plays the appropriate animation based on player state.
func play_animation() -> void:

	# Check if the animation player is not locked
	if !player.is_animation_locked:

		# Check if the player is moving
		if player.velocity != Vector3.ZERO:

			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != player.animation_swimming:

				# Adjust player visuals for animation
				player.visuals_aux_scene.position.y = lerp(player.visuals_aux_scene.position.y, player.collision_height/2, 0.25)

				# Play the "swimming" animation
				player.animation_player.play(player.animation_swimming)

		# The player must not be moving
		else:

			# Check if the animation player is not already playing the appropriate animation
			if player.animation_player.current_animation != player.animation_treading_water:

				# [Re]set the player visuals postion
				player.visuals_aux_scene.position.y = player.collision_height / 4

				# Play the "treading water" animation
				player.animation_player.play(player.animation_treading_water)


## Start "swimming".
func start() -> void:

	# Enable _this_ state node
	process_mode = PROCESS_MODE_INHERIT

	# Set the player's new state
	player.current_state = States.State.SWIMMING

	# Flag the player as "swimming"
	player.is_swimming = true

	# Set the player's speed
	player.speed_current = player.speed_swimming

	# Slow the player down
	player.velocity.y = player.velocity.y * 0.0

	# Get positional information
	var parent_position = player.swimming_in.get_parent().position
	var child_size = player.swimming_in.get_child(0).shape.size
	var water_top = player.swimming_in.get_parent().position.y + (child_size.y / 2)
	var player_half_height = player.collision_height / 2
	
	# Check if the player is below water level
	if (player.position.y + player_half_height) < (parent_position.y + water_top):

		# Set the player's vertical position to be at water level
		player.position.y = water_top - player_half_height


## Stop "swimming".
func stop() -> void:

	# Disable _this_ state node
	process_mode = PROCESS_MODE_DISABLED

	# Flag the player as not "swimming"
	player.is_swimming = false

	# [Re]set the player visuals postion
	player.visuals_aux_scene.position.y = player.collision_height / 2
