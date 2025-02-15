extends Node3D

var camera: Camera3D
@onready var camera_mount: Node3D = $CameraMount
var mesh_instance: MeshInstance3D
var material_override: Material
var sub_viewport: SubViewport
var sub_viewport_texture: ViewportTexture


## Called when the node enters the scene tree for the first time.
func _ready() -> void:

	mesh_instance = $MeshInstance3D

	# Get the shader material
	var shader_material = mesh_instance.mesh.material as ShaderMaterial

	# Get the SubViewport
	var viewport = $MeshInstance3D/SubViewport

	# Set the viewport texture as the shader parameter
	shader_material.set_shader_parameter("viewport_texture", viewport.get_texture())


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:

	# Get the 🎥 camera attached to the 🔵 Blue Portal's viewport
	camera = $"../BluePortal/MeshInstance3D/SubViewport/Camera3D"

	# Check if the camera was located
	if camera != null:

		# Move the 🎥 camera from behind the 🔵 Blue Portal to behind the 🔴 Red Portal,
		# so that the 🔴 Red Portal's SubViewport now displays what it would look like looking out of the 🔵 Blue Portal.
		camera.global_transform = camera_mount.global_transform


## Called when a Node3D enters _this_ Area3D.
func _on_body_entered(body: Node3D) -> void:

	# Check if collision was caused by a player
	if body is CharacterBody3D:

		# Continue only if the portal is present
		if camera != null:

			body.global_transform = $"../BluePortal/ExitPoint".global_transform
