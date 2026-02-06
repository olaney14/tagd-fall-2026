extends Node2D
class_name GearBoard

const SIZE_X = 700
const SIZE_Y = 575

@export var hole_image: PackedScene
@export var grid_size: Vector2i

@onready var board = $Board
@onready var gears = $Board/Gears
@onready var pegs  = $Board/Pegs
@onready var spacing_x = SIZE_X / grid_size.x
@onready var spacing_y = SIZE_Y / grid_size.y

var selected_gear: Gear = null
var selection_offset = Vector2(0, 0)

func populate():
	for i in range(grid_size.y):
		for j in range(grid_size.x):
			var image: Node2D = hole_image.instantiate()
			pegs.add_child(image)
			image.position = Vector2(i * spacing_x, j * spacing_y)

func init_gears():
	for gear in gears.get_children():
		if gear is Gear:
			gear.connected_board = self

func reposition():
	for gear in gears.get_children():
		if gear is Gear:
			gear.position = Vector2(gear.slot_x * spacing_x, gear.slot_y * spacing_y)

func gear_pressed(gear: Gear, offset: Vector2):
	if not selected_gear:
		selection_offset = offset
		selected_gear = gear

func lmb_released():
	if selected_gear and selected_gear is Gear:
		selected_gear.slot_x = round(selected_gear.position.x / spacing_x)
		selected_gear.slot_y = round(selected_gear.position.y / spacing_y)
		reposition()
	selected_gear = null

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_released() and event.button_index == MOUSE_BUTTON_LEFT:
		lmb_released()

func _ready() -> void:
	populate()
	init_gears()
	reposition()

func _process(_delta: float) -> void:
	var mouse_pos = board.to_local(get_viewport().get_mouse_position())
	if selected_gear and selected_gear is Gear:
		selected_gear.position = mouse_pos + selection_offset
