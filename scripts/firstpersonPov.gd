extends Node3D
var edge_margin = 50 # Pixels from edge to trigger rotation
var senstivity = 0.01
@onready var viewport = get_viewport()
@onready var head = $"."
@onready var camera = $Camera

func _process(delta):
	var mouse_pos = viewport.get_mouse_position()
	var viewport_size = viewport.size
	
	# Rotate right
	if mouse_pos.x > viewport_size.x - edge_margin:
		head.rotate_y(-senstivity)
	# Rotate left
	elif mouse_pos.x < edge_margin:
		head.rotate_y(senstivity)
		
	# Vertical rotation (optional)
	if mouse_pos.y > viewport_size.y - edge_margin:
		camera.rotate_x(-senstivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))
	elif mouse_pos.y < edge_margin:
		camera.rotate_x(senstivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))
