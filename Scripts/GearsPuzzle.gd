extends Node2D
class_name GearBoard

#const SIZE_X = 700
#const SIZE_Y = 575
const SPACING = 100

@export var hole_image: PackedScene
@export var grid_size: Vector2i
@export var locked_gear_pos: Vector2i
@export var turn_speed: float

@onready var board = $Board
@onready var board_gears = $Board/Gears
@onready var pegs  = $Board/Pegs
@onready var backpack_area = $Backpack/BackpackArea
@onready var backpack_gears = $Backpack/Gears
@onready var locked_gear = $Board/Gears/LockedGear

var selected_gear: Gear = null
var selection_offset = Vector2(0, 0)

var blocked_matrix = []
var gear_matrix = []
#var connection_matrix = []

func in_grid_bounds(pos: Vector2i):
	return pos.x >= 0 && pos.y >= 0 && pos.x < grid_size.x && pos.y < grid_size.y

func populate():
	for i in range(grid_size.y):
		for j in range(grid_size.x):
			var image: Node2D = hole_image.instantiate()
			pegs.add_child(image)
			image.position = Vector2(i * SPACING, j * SPACING)

func reset_matrix(mat: Array, base):
	mat.clear()
	for i in range(grid_size.x * grid_size.y):
		mat.push_back(base)
			
func at(x: int, y: int) -> int:
	return y * grid_size.x + x
	
func at_2i(pos: Vector2i):
	return pos.y * grid_size.x + pos.x

func reset_all_matrices():
	reset_matrix(gear_matrix, null)
	reset_matrix(blocked_matrix, false)

func repopulate_matrices():
	for gear in board_gears.get_children():
		if gear is Gear:
			gear_matrix[at(gear.slot_x, gear.slot_y)] = gear
			for offset in gear.blocked_spaces:
				blocked_matrix[at(gear.slot_x + offset.x, gear.slot_y + offset.y)] = true
			for offset in gear.connect_from_spaces:
				connection_matrix[at(gear.slot_x + offset.x, gear.slot_y + offset.y)] = gear
				print("Connection @ " + str(gear.slot_x + offset.x) + ", " + str(gear.slot_y + offset.y))

func init_gears():
	reset_all_matrices()
	for gear in board_gears.get_children():
		if gear is Gear:
			gear.connected_board = self
	for gear in backpack_gears.get_children():
		if gear is Gear:
			gear.connected_board = self
	locked_gear.position = Vector2(locked_gear_pos.x * SPACING, locked_gear_pos.y * SPACING)

var current_gear_chain = []
var chain_jam = false

var locked_gear_connections = [
	Vector2i(1, 0),
	Vector2i(-1, 0),
	Vector2i(0, 1),
	Vector2i(0, -1)
]
var locked_gear_turn = 1
var rotation_offset_step = PI / 8

func compute_gear_chain(gear: Gear, pos: Vector2i):
	if gear in current_gear_chain:
		return
	current_gear_chain.push_back(gear)
	for offset in gear.connect_to_spaces:
		var con_pos = pos + offset
		if not in_grid_bounds(con_pos):
			continue
		var connection_possible = connection_matrix[at_2i(con_pos)]
		if connection_possible != null:
			if gear.turn == connection_possible.turn:
				chain_jam = true
			connection_possible.turn = -gear.turn
			connection_possible.rotation_offset = gear.rotation_offset + rotation_offset_step
			compute_gear_chain(connection_possible, con_pos)

func reposition():
	for gear in board_gears.get_children():
		if gear is Gear:
			gear.position = Vector2(gear.slot_x * SPACING, gear.slot_y * SPACING)
			gear.turn = 0
			# gear.rotation = 0
	reset_all_matrices()
	repopulate_matrices()
	chain_jam = false
	current_gear_chain = []
	for gear in backpack_gears.get_children():
		if gear is Gear:
			gear.position = gear.backpack_pos
			gear.turn = 0
	for con in locked_gear_connections:
		var con_pos: Vector2i = locked_gear_pos + con
		if not in_grid_bounds(con_pos):
			continue
		var connection_possible = connection_matrix[at_2i(con_pos)]
		# print(at_2i(con_pos))
		# print(connection_possible)
		print("Checking @ " + str(con_pos))
		if connection_possible != null:
			connection_possible.turn = -locked_gear_turn
			connection_possible.rotation_offset = rotation_offset_step
			print("Computing gear chain from locked gear")
			compute_gear_chain(connection_possible, con_pos)
	for gear in board_gears.get_children():
		if gear is Gear and gear not in current_gear_chain:
			gear.rotation = 0
			gear.rotation_offset = 0

func gear_pressed(gear: Gear, offset: Vector2):
	if not selected_gear:
		selection_offset = offset
		selected_gear = gear

func lmb_released():
	if selected_gear and selected_gear is Gear:
		if backpack_area.overlaps_area(selected_gear.inner_area):
			selected_gear.on_grid = false
			selected_gear.backpack_pos = backpack_area.to_local(selected_gear.global_position)
			selected_gear.reparent(backpack_gears)
		else:
			selected_gear.on_grid = true
			selected_gear.slot_x = clamp(round(selected_gear.position.x / SPACING), 0, grid_size.x - 1)
			selected_gear.slot_y = clamp(round(selected_gear.position.y / SPACING), 0, grid_size.y - 1)
			selected_gear.reparent(board_gears)
		reposition()
	selected_gear = null

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_released() and event.button_index == MOUSE_BUTTON_LEFT:
		lmb_released()

func _ready() -> void:
	populate()
	init_gears()
	reposition()

var cur_rotation = 0

func _process(_delta: float) -> void:
	cur_rotation += _delta
	var mouse_pos = board.to_local(get_viewport().get_mouse_position())
	if selected_gear and selected_gear is Gear:
		selected_gear.position = mouse_pos + selection_offset
	locked_gear.rotation = cur_rotation * locked_gear_turn * turn_speed
	for gear in board_gears.get_children():
		if gear is Gear:
			gear.rotation = cur_rotation * gear.turn * turn_speed * gear.rotation_multiplier + gear.rotation_offset
			#gear.rotate(gear.turn * turn_speed)
