extends Area2D

# Drag your button node here in the inspector
var _player_in_area = false

func _on_body_entered(body):
	# Check if the entered body is the player by checking its name,
	# or by checking its group (e.g., "Player"), or using a class_name.
	if body.name == "Player":
	# or if body.is_in_group("Player"):
		_player_in_area = true
		print("Player entered the collision box!")

func _on_body_exited(body):
	if body.name == "Player":
		_player_in_area = false
		print("Player exited the collision box!")
