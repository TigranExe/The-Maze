extends Node
class_name SuperMenu

var current_ordered_button_position_array_index: int = 0: set = set_current_ordered_button_position_array_index
var ordered_button_position_array: Array[Vector2]
@onready var player = $"2DObjects/PlayerSprite"
@onready var tether = $"2DObjects/TetherPoint"

var has_menu_been_set_up: bool = false

func _ready() -> void:
	pass

func set_up_cursor_selection(): #This can't be at _ready() because UI doesn't set up yet
	for node in $Control/MarginContainer/VSplitContainer.get_children():
		if node is Button:
			ordered_button_position_array.append(node.global_position)

func _physics_process(delta: float) -> void:
	if !has_menu_been_set_up:
		if Input.is_anything_pressed():
			set_up_cursor_selection()
			has_menu_been_set_up = true
	if Input.is_action_just_pressed("ui_down"):
		if current_ordered_button_position_array_index == ordered_button_position_array.size() - 1:
			current_ordered_button_position_array_index = 0
		else:
			current_ordered_button_position_array_index += 1
	if Input.is_action_just_pressed("ui_up"):
		if current_ordered_button_position_array_index == 0:
			current_ordered_button_position_array_index = ordered_button_position_array.size() - 1
		else:
			current_ordered_button_position_array_index -= 1
	if Input.is_action_just_pressed("ui_accept"):
		for node in $Control/MarginContainer/VSplitContainer.get_children():
			if node is Button:
				if node.global_position == ordered_button_position_array[current_ordered_button_position_array_index]:
					node.emit_signal("pressed") #YYYYYYESSSS THIS WORKS

func set_current_ordered_button_position_array_index(new_index: int):
	current_ordered_button_position_array_index = new_index
	tether.global_position.y = ordered_button_position_array[new_index].y
