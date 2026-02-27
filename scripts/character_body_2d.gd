extends CharacterBody2D

@export var speed: float = 500.0
@export var jump_velocity: float = -400.0

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y += jump_velocity
	
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		
	

	move_and_slide()
	#&& body.is_in_group("puzzle")


var interaction = false
func _on_elevator_area_body_entered(body: Node2D) -> void:
	interaction = true
	print("entering elev")
	$"../Elevator area/Sprite2D".show()
	

func _on_elevator_area_body_exited(body: Node2D) -> void:
	print("leaving elev")
	interaction = false
	$"../Elevator area/Sprite2D".hide()
func _process(delta):
	if interaction and Input.is_action_just_pressed("interact"):
		print("Change Scene")
		get_tree().change_scene_to_file("res://scenes/elevator.tscn")
