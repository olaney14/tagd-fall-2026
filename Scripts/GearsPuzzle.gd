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
@onready var backpack_origin = $Backpack/Origin
@onready var dragging_store = $Dragging

var selected_gear: Gear = null
var previous_position = null
var selection_offset = Vector2(0, 0)

var gear_matrix = []

# shorthand
func v2i(x: int, y: int) -> Vector2i:
	return Vector2i(x, y)

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

func print_matrix(mat):
	print("[")
	for y in range(grid_size.y):
		var s = "\t"
		for x in range(grid_size.x):
			s += str(mat[at(x, y)]) + ", "
		print(s)
	print("]")

# return true if the gear collides
func collide_gear(gear: Gear, at: Vector2i) -> bool:
	if gear.gear_type == "small":
		if at == locked_gear_pos:
			return true
		if gear_matrix[at_2i(at)]:
			return true
		for dir in cardinals:
			var spot = gear_matrix[at_2i(at + dir)]
			if spot and spot.gear_type == "med":
				return true 
	elif gear.gear_type == "med":
		for dir in cardinals + [v2i(0, 0)]:
			var spot = at + dir
			if spot == locked_gear_pos:
				return true
			if in_grid_bounds(spot) and gear_matrix[at_2i(spot)]:
				return true
		# forbid diagonals with large gears
		for dir in diagonals:
			var spot = at + dir
			if in_grid_bounds(spot):
				var found = gear_matrix[at_2i(spot)]
				if found and found.gear_type == "med":
					return true
	
	return false

func repopulate_matrices():
	for gear in board_gears.get_children():
		if gear is Gear:
			gear_matrix[at(gear.slot_x, gear.slot_y)] = gear

func place_gear(gear: Gear, x: int, y: int) -> bool:
	if collide_gear(gear, v2i(x, y)):
		return false
			
	gear_matrix[at(x, y)] = gear
	gear.slot_x = x
	gear.slot_y = y
	gear.on_grid = true
	gear.reparent(board_gears)
	return true

func init_gears():
	#reset_all_matrices()
	reset_matrix(gear_matrix, null)
	for gear in board_gears.get_children():
		if gear is Gear:
			gear.connected_board = self
	for gear in backpack_gears.get_children():
		if gear is Gear:
			gear.connected_board = self
	locked_gear.position = Vector2(locked_gear_pos.x * SPACING, locked_gear_pos.y * SPACING)

var current_gear_chain = []
var chain_jam = false

var cardinals = [
	v2i( 1, 0),
	v2i(-1, 0),
	v2i(0,  1),
	v2i(0, -1)
]

var diagonals = [
	v2i(-1, -1),
	v2i( 1, -1),
	v2i(-1,  1),
	v2i( 1,  1)
]

var locked_gear_turn = 1
var rotation_offset_step = PI / 8

func link_small_gear(pos: Vector2i) -> Array[Gear]:
	var links: Array[Gear] = []
	for off in cardinals:
		var link = off + pos
		if not in_grid_bounds(link):
			continue
		var gear = gear_matrix[at_2i(link)]
		if gear and gear is Gear and gear.gear_type == "small":
			links.push_back(gear)
			
	for off in diagonals:
		var link = off + pos
		if not in_grid_bounds(link):
			continue
		var gear = gear_matrix[at_2i(link)]
		if gear and gear is Gear and gear.gear_type == "med":
			links.push_back(gear)
			
	return links

func link_med_gear(pos: Vector2i) -> Array[Gear]:
	var links: Array[Gear] = []
	for off in diagonals:
		var link = pos + off
		if not in_grid_bounds(link):
			continue
		var gear = gear_matrix[at_2i(link)]
		if gear and gear is Gear and gear.gear_type == "small":
			links.push_back(gear)
			
	return links

func compute_gear_chain(gear: Gear, pos: Vector2i):
	if gear in current_gear_chain:
		return
	current_gear_chain.push_back(gear)
	if gear.gear_type == "small":
		for link in link_small_gear(pos):
			link.turn = -gear.turn
			link.rotation_offset = gear.rotation_offset + rotation_offset_step
			compute_gear_chain(link, link.grid_pos())
	elif gear.gear_type == "med":
		for link in link_med_gear(pos):
			link.turn = -gear.turn
			link.rotation_offset = gear.rotation_offset + rotation_offset_step
			compute_gear_chain(link, link.grid_pos())

func reposition():
	for gear in board_gears.get_children():
		if gear is Gear:
			gear.position = Vector2(gear.slot_x * SPACING, gear.slot_y * SPACING)
			gear.turn = 0
	reset_matrix(gear_matrix, null)
	repopulate_matrices()
	chain_jam = false
	current_gear_chain = []
	for gear in backpack_gears.get_children():
		if gear is Gear:
			gear.position = gear.backpack_pos
			gear.turn = 0
	for link in link_small_gear(locked_gear_pos):
		link.turn = -locked_gear_turn
		link.rotation_offset = rotation_offset_step
		compute_gear_chain(link, link.grid_pos())
	for gear in board_gears.get_children():
		if gear is Gear and gear not in current_gear_chain:
			gear.rotation = 0
			gear.rotation_offset = 0

func gear_pressed(gear: Gear, offset: Vector2):
	if not selected_gear:
		selection_offset = offset
		selected_gear = gear
		if gear.on_grid:
			previous_position = gear.grid_pos()
		gear_matrix[at_2i(gear.grid_pos())] = null
		gear.on_grid = false
		gear.reparent(dragging_store)
		reset_matrix(gear_matrix, null)
		repopulate_matrices()

func lmb_released():
	if selected_gear and selected_gear is Gear:
		if backpack_area.overlaps_area(selected_gear.inner_area):
			selected_gear.on_grid = false
			selected_gear.backpack_pos = backpack_area.to_local(selected_gear.global_position)
			selected_gear.reparent(backpack_gears)
		else:
			var target_x = clamp(round(selected_gear.position.x / SPACING), 0, grid_size.x - 1)
			var target_y = clamp(round(selected_gear.position.y / SPACING), 0, grid_size.y - 1)
			if not place_gear(selected_gear, target_x, target_y):
				if previous_position:
					selected_gear.slot_x = previous_position.x
					selected_gear.slot_y = previous_position.y
					selected_gear.on_grid = true
					selected_gear.reparent(board_gears)
				else:
					selected_gear.on_grid = false
					selected_gear.backpack_pos = backpack_origin.position + \
						Vector2(randf_range(0, 250), randf_range(0, 500))
					selected_gear.reparent(backpack_gears)
		previous_position = null
					
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
			gear.rotation = cur_rotation * gear.turn * turn_speed * gear.rotation_multiplier \
				+ (gear.rotation_offset * gear.rotation_multiplier)
