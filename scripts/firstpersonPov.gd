extends Node3D
var edge_margin = 100 # Pixels from edge to trigger rotation
var senstivity = 1
@onready var viewport = get_viewport()
@onready var head = $"."
@onready var camera = $Camera
@onready var interaction_ray = $RayCast3D
func _process(delta):
	# Rotate right
	if Input.is_action_pressed("right"):
		head.rotate_y(-senstivity * delta)
	# Rotate left
	elif Input.is_action_pressed("left"):
		head.rotate_y(senstivity * delta)
		
	# Vertical rotation (optional)
	if Input.is_action_pressed("down"):
		camera.rotate_x(-senstivity * delta)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))
	elif Input.is_action_pressed("up"):
		camera.rotate_x(senstivity * delta)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))
		

	
	#var mouse_pos = viewport.get_mouse_position()
	#var viewport_size = viewport.size
	#
	## Rotate right
	#if mouse_pos.x > viewport_size.x - edge_margin:
		#head.rotate_y(-senstivity)
	## Rotate left
	#elif mouse_pos.x < edge_margin:
		#head.rotate_y(senstivity)
		#
	## Vertical rotation (optional)
	#if mouse_pos.y > viewport_size.y - edge_margin:
		#camera.rotate_x(-senstivity)
		#camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))
	#elif mouse_pos.y < edge_margin:
		#camera.rotate_x(senstivity)
		#camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if interaction_ray.is_colliding():
			print_debug("The pew pew reached")
			var collider = interaction_ray.get_collider()	
		print("press pew pew")
func _unhandled_input(event):
	pass
