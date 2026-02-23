extends Area2D

var custom_cursor = preload("res://sprites/mouseSprites/mouse eye.png")

func _on_mouse_entered():
	print("look ma im on camera")
	Input.set_custom_mouse_cursor(custom_cursor)

func _on_mouse_exited():
	print("CURSE YOU EVIL WRETCHED GODS ABOVE LET ME BE FREEEEEEEE")
	Input.set_custom_mouse_cursor(null)
