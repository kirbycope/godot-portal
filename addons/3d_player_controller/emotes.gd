extends Control
## emotes.gd

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

const ANIMATION_CLAPPING := "Clapping" + "/mixamo_com"
const ANIMATION_CRYING := "Crying" + "/mixamo_com"
const ANIMATION_QUICK_INFORMAL_BOW := "Quick_Informal_Bow" + "/mixamo_com"
const ANIMATION_WAVING := "Waving" + "/mixamo_com"

# Note: `@onready` variables are set when the scene is loaded.
@onready var player: CharacterBody3D = get_parent().get_parent().get_parent()


## Called once for every event before _unhandled_input(), allowing you to consume some events.
func _input(event) -> void:
	# Check if the game is paused
	if player.game_paused:
		# Disable visibility
		visible = false
	# The game must not be paused
	else:
		# Check if emotes are enabled
		if player.enable_emotes:
			# Check if the control is visible
			if visible:
				# Check if the player is not on the floor
				if !player.is_on_floor():
					# Disable visibility
					visible = false

				# Check if the [dpad_down] action _pressed_
				if event.is_action_pressed("dpad_down"):
					# Perform emote 4
					emote4()

				# Check if the [dpad_left] action _pressed_
				if event.is_action_pressed("dpad_left"):
					# Perform emote 2
					emote2()

				# Check if the [dpad_right] action _pressed_
				if event.is_action_pressed("dpad_right"):
					# Perform emote 3
					emote3()

				# Check if the [dpad_up] action _pressed_
				if event.is_action_pressed("dpad_up"):
					# Perform emote 1
					emote1()

			# The control must not be visible
			if !visible:
				if player.animation_player.current_animation in [
					ANIMATION_WAVING,
					ANIMATION_CLAPPING,
					ANIMATION_CRYING,
					ANIMATION_QUICK_INFORMAL_BOW,
				]:
					return

				# Check if the [dpad_left] action _pressed_
				if event.is_action_pressed("dpad_left"):
					# Enable visibility
					visible = true

				# Check if the menu was opened using controller based input
				if Input.is_joy_button_pressed(0, JOY_BUTTON_DPAD_LEFT):
					# Show the dpad emote controls
					$DPad.visible = true
					# Hide the keyboard emote controls
					$Keyboard.visible = false

				# Check if the menu was opened using keyboard based input
				elif Input.is_key_pressed(KEY_B):
					# Hide the dpad emote controls
					$DPad.visible = false
					# Show the keyboard emote controls
					$Keyboard.visible = true




## Called when the emote 1 button is pressed.
func _on_emote_1_button_button_down() -> void:
	# Perform emote 1
	emote1()


## Called when the emote 2 button is pressed.
func _on_emote_2_button_button_down() -> void:
	# Perform emote 2
	emote2()


## Called when the emote 3 button is pressed.
func _on_emote_3_button_button_down() -> void:
	# Perform emote 3
	emote3()


## Called when the emote 4 button is pressed.
func _on_emote_4_button_button_down() -> void:
	# Perform emote 4
	emote4()


## Performs emote 1.
func emote1() -> void:
	# Play the "waving" animation
	player.animation_player.play(ANIMATION_WAVING)

	# Flag the animation player as locked
	player.is_animation_locked = true

	# Disable the emote menu's visibility
	visible = false


## Performs emote 2.
func emote2() -> void:
	# Play the "clapping" animation
	player.animation_player.play(ANIMATION_CLAPPING)

	# Flag the animation player as locked
	player.is_animation_locked = true

	# Disable the emote menu's visibility
	visible = false


## Performs emote 3.
func emote3() -> void:
	# Play the "crying" animation
	player.animation_player.play(ANIMATION_CRYING)

	# Flag the animation player as locked
	player.is_animation_locked = true

	# Disable the emote menu's visibility
	visible = false


## Performs emote 4.
func emote4() -> void:
	# Play the "bowing" animation
	player.animation_player.play(ANIMATION_QUICK_INFORMAL_BOW)

	# Flag the animation player as locked
	player.is_animation_locked = true

	# Disable the emote menu's visibility
	visible = false
