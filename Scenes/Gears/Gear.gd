extends Node2D
class_name Gear

@onready var area = $Area2D
@onready var inner_area = $MiddleArea

#@export var blocked_spaces: Array[Vector2i]
#@export var connect_to_spaces: Array[Vector2i]
#@export var connect_from_spaces: Array[Vector2i]
@export var gear_type: String
@export var rotation_multiplier: float = 1.0

var on_grid = true
var slot_x = 0
var slot_y = 0
var backpack_pos = Vector2(0, 0)
var connected_board: GearBoard = null
var rotation_offset = 0

var turn = 0

func _gear_clicked(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	var offset = global_position - event.position
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not connected_board:
			push_warning("Gear was not initialized correctly")
			return
		if event.is_pressed():
			connected_board.gear_pressed(self, offset)
