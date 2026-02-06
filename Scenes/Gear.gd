extends Node2D
class_name Gear

var slot_x = 0
var slot_y = 0
var connected_board: GearBoard = null

func _gear_clicked(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	var offset = global_position - event.position
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not connected_board:
			push_warning("Gear was not initialized correctly")
			return
		if event.is_pressed():
			connected_board.gear_pressed(self, offset)
