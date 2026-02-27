extends Area2D

func _on_input_event(viewport, event, shape_idx):
	# Check if the event is a mouse button click
	if event is InputEventMouseButton:
		# Check if it's the left button and it was pressed down
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("Clicked on: thing")
			# Add your interaction logic here (e.g., queue_free() to delete)
			
