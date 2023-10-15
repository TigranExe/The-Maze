extends Node2D


@onready var player = $Grid/MazeCharacter
#it is slighty awful I didn't onready the important labels but HEY


var is_turn_timer_active: bool = false #I probably should have not had any "is" in my bools
var turn_timer_countdown: float = 8

var out_of_screen_position: Vector2 = Vector2(-42,-42)

var distance_between_tile_centers: int = 100
var grid_tile_width: int = 5
var grid_tile_height: int = 5
var center_of_top_left_tile_position: Vector2
var center_of_bottom_right_tile_position: Vector2



var direction_dict = {
	"up" : Vector2(0,-1),
	"down" : Vector2(0,1),
	"left" : Vector2(-1,0),
	"right" : Vector2(1,0)
}



var room_dictionary: Dictionary = {
	
}

func _ready() -> void:
	do_grid_adjustments()
	

func refresh_the_board():
	player.position = Vector2(60,60)
	if is_turn_timer_active:
		$TurnTimer.start()


func do_grid_adjustments(): 
	distance_between_tile_centers = distance_between_tile_centers * $Grid.scale.y
	center_of_top_left_tile_position = $Grid.global_position ##I need to move this just a bit I think
	center_of_bottom_right_tile_position.x = center_of_top_left_tile_position.x + (grid_tile_width - 1) \
	* distance_between_tile_centers
	center_of_bottom_right_tile_position.y = center_of_top_left_tile_position.y + (grid_tile_height- 1) \
	* distance_between_tile_centers
	print(center_of_bottom_right_tile_position)

func _physics_process(delta: float) -> void:
	check_inputs()


func check_inputs() -> void:
	if Input.is_action_just_pressed("ui_down"):
		attempt_move(direction_dict["down"])
	if Input.is_action_just_pressed("ui_up"):
		attempt_move(direction_dict["up"])
	if Input.is_action_just_pressed("ui_right"):
		attempt_move(direction_dict["right"])
	if Input.is_action_just_pressed("ui_left"):
		attempt_move(direction_dict["left"])
 



##Add fail conditions and whatever

func attempt_move(move_direction: Vector2): ##
	##Add stuff about communicating what's happening
	##Check if tile is occupied or something
	var attempted_move_position = player.global_position + (move_direction * distance_between_tile_centers)
	#add_text_to_step_log("Attempt to go " + str(direction_dict.find_key(move_direction)))
	if is_position_in_grid(attempted_move_position):
		player.global_position = attempted_move_position
		#add_text_to_step_log("You went " + str(direction_dict.find_key(move_direction)) + "!")
		end_turn()
	else:
		#Double check for secrets
		flash_the_grid()
		#add_text_to_step_log("Too far from center")

func is_position_in_grid(given_position: Vector2) -> bool: ##
	if given_position.x > center_of_bottom_right_tile_position.x:
		return false
	if given_position.x < center_of_top_left_tile_position.x:
		return false
	if given_position.y > center_of_bottom_right_tile_position.y:
		return false
	if given_position.y < center_of_top_left_tile_position.y:
		return false
	return true


func this_invalid_move_was_made(in_which_direction: Vector2): #yes this could/should be a signal
	flash_the_grid()
	var invalid_direction: Vector2
	invalid_direction = in_which_direction
	if direction_dict["up"]: #I like match more but I keep getting errors
		pass
	if direction_dict["down"]:
		pass
	if direction_dict["left"]:
		pass
	if direction_dict["right"]:
		pass

func flash_the_grid():
#	var current_tween = create_tween()
#	current_tween.tween_property($Grid, "position", $Grid.global_position + Vector2(3,0), 0.04)
#	current_tween.tween_property($Grid, "position", $Grid.global_position - Vector2(3,0), 0.04)
	pass


func end_turn():
	pass
	



func kill_player():
	refresh_the_board()


func get_random_outer_tile_direction() -> Vector2:
	var enemy_travel_direction: Vector2
	var counter: int
	var random_int = randi_range(0,3) ##There MUST be a better way to randomly get something from a dict but whatever
	for direction_name in direction_dict:
		if counter == random_int:
			enemy_travel_direction = direction_dict[direction_name]
		counter += 1
	return enemy_travel_direction

func get_random_outer_tile_position() -> Vector2:
	var which_outer_tile_position: Vector2
	var test_direction = get_random_outer_tile_direction()
	which_outer_tile_position = get_outer_tile_position_on_opposing_edge(test_direction)
	return which_outer_tile_position

func get_outer_tile_position_on_opposing_edge(given_direction: Vector2) -> Vector2:
	var tile_number:int = randi_range(1,grid_tile_width)
	var which_outer_tile_position: Vector2
	if given_direction == direction_dict["up"] or given_direction == direction_dict["down"]:
		which_outer_tile_position.x = center_of_top_left_tile_position.x + ((tile_number - 1) * distance_between_tile_centers)
		if given_direction == direction_dict["up"]: #Below might need to be grid_tile_height
			which_outer_tile_position.y = center_of_top_left_tile_position.y + ((grid_tile_width -1 ) * distance_between_tile_centers)
		if given_direction == direction_dict["down"]:
			which_outer_tile_position.y = center_of_top_left_tile_position.y
	else:
		which_outer_tile_position.y = center_of_top_left_tile_position.y + ((tile_number - 1) * distance_between_tile_centers)
		if given_direction == direction_dict["left"]: 
			which_outer_tile_position.x = center_of_top_left_tile_position.x + ((grid_tile_height -1 ) * distance_between_tile_centers)
		if given_direction == direction_dict["right"]:
			which_outer_tile_position.x = center_of_top_left_tile_position.x
	return which_outer_tile_position





#Ok so like I'm thinking of a step by step system where each step that's attempted
#Is slowly revealed which I have the tech for but whatever that's too slow

#Questions!
#func clear_step_log():
#	for written_label_step in step_log.get_children():
#		written_label_step.queue_free()
#
#func add_text_to_step_log(given_text: String):
#	#oooh I can add colors or effects with RichText
#	var new_label = Label.new()
#	step_log.add_child(new_label)
#	new_label.text = given_text

