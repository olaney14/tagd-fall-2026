extends Area2D

var custom_cursor = load("res://sprites/mouseSprites/mouse eye.png")

func _on_mouse_entered():
	# Set custom cursor with optional hotspot
	Input.set_custom_mouse_cursor(custom_cursor)

func _on_mouse_exited():
	# Changes back to the arrow
	Input.set_custom_mouse_cursor(null)
