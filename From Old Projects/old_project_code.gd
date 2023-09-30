extends Node2D
class_name GameMaster


@onready var player = %Player
@onready var tether_point = %TetherPoint
@onready var enemy_collection = %EnemyCollection
@onready var step_log = %StepLogVB
#it is slighty awful I didn't onready the important labels but HEY
@onready var spawnable_enemy = preload("res://HandyScenes/enemy.tscn")

var present_turns_alive: int = 0
var maximum_turns_this_round: int = 10
var present_turns_left_this_round: int = 10 #Wanted so that there's rounds and you needed to use the action
var maximum_turns_prior_using_action: int = 10
var present_turns_left_until_death_from_action_nonuse: int = 10
enum Mode {TUTORIAL, GAMEPLAY, CINEMATIC}
var current_mode: Mode = Mode.TUTORIAL: set = set_current_mode
enum Tutorial_Step {MOVE,GRID,ACTION,ENEMY,GROUP, EXIT}
var current_tutorial_step: Tutorial_Step = Tutorial_Step.MOVE: set = set_current_tutorial_step
var where_latest_enemies_spawned: Array[Vector2] = []
var is_turn_timer_active: bool = false #I probably should have not had any "is" in my bools
var turn_timer_countdown: float = 8

var out_of_screen_position: Vector2 = Vector2(-42,-42)

var distance_between_tile_centers: int = 30
var grid_tile_width: int = 5
var grid_tile_height: int = 5
var center_of_top_left_tile_position: Vector2
var center_of_bottom_right_tile_position: Vector2

var is_spawning_enemies: bool = true
var enemies_spawned_per_turn: int = 2

enum Group {
	GRIDWRATH,
	TUNNELERS,
	GROUPLESS
}
var current_group: Group = Group.GRIDWRATH #Add group capabilites



var direction_dict = {
	"up" : Vector2(0,-1),
	"down" : Vector2(0,1),
	"left" : Vector2(-1,0),
	"right" : Vector2(1,0)
}

func _ready() -> void:
	do_grid_adjustments()
	if SetChanges.does_gameplay_start_with_tutorial:
		current_mode = Mode.TUTORIAL
	else:
		current_mode = Mode.GAMEPLAY
	$UI/Themer/QuoteLabel.text = SetChanges.tethered_quote
	

func refresh_the_board():
	is_spawning_enemies = true
	present_turns_alive = 0
	maximum_turns_this_round = 10
	present_turns_left_this_round = 10
	present_turns_left_until_death_from_action_nonuse = maximum_turns_prior_using_action
	reset_tether_point()
	$UI/Themer/Control.visible = true
	step_log.visible = true
	player.position = Vector2(60,60)
	if is_turn_timer_active:
		$TurnTimer.start()
	kill_all_enemies()

func kill_all_enemies():
	for enemy in enemy_collection.get_children():
		kill_enemy(enemy)

func reset_tether_point():
	tether_point.position = Vector2(30,30)


func do_grid_adjustments(): 
	distance_between_tile_centers = distance_between_tile_centers * $GridPanel.scale.y
	center_of_top_left_tile_position = $GridPanel.global_position ##I need to move this just a bit I think
	center_of_bottom_right_tile_position.x = center_of_top_left_tile_position.x + (grid_tile_width - 1) * distance_between_tile_centers
	center_of_bottom_right_tile_position.y = center_of_top_left_tile_position.y + (grid_tile_height- 1) * distance_between_tile_centers
	print(center_of_bottom_right_tile_position)

func _physics_process(delta: float) -> void:
	check_inputs()
	check_and_set_tutorial_step_completion()

func check_and_set_tutorial_step_completion():
	if current_mode == Mode.TUTORIAL:
		match current_tutorial_step: #Please let me know if you have a better solution to tutorials
			Tutorial_Step.MOVE:
				if player.global_position == center_of_top_left_tile_position:
					current_tutorial_step = Tutorial_Step.GRID
			Tutorial_Step.GRID:
				if tether_point.global_position == center_of_top_left_tile_position:
					current_tutorial_step = Tutorial_Step.ACTION
			Tutorial_Step.ACTION:
				if Input.is_action_just_pressed("ui_accept"):
					if player.global_position != tether_point.global_position:
						current_tutorial_step = Tutorial_Step.ENEMY
			Tutorial_Step.ENEMY:
				if enemy_collection.get_children().size() == 0:
					current_tutorial_step = Tutorial_Step.GROUP
			Tutorial_Step.GROUP:
				if player.global_position == $GridPanel/CentralTether.global_position:
					current_tutorial_step = Tutorial_Step.EXIT
			

func set_current_tutorial_step(given_step: Tutorial_Step):
	current_tutorial_step = given_step
	match current_tutorial_step:
		Tutorial_Step.MOVE:
			player.position = Vector2(60,60)
			$UI/Themer/C3/TutorialLabel.text = "try moving as far up and left"
		Tutorial_Step.GRID:
			step_log.visible = true
			$UI/Themer/C3/TutorialLabel.text = "Nice! You're bound to stay close. Try your action here"
		Tutorial_Step.ACTION:
			$UI/Themer/C3/TutorialLabel.text = "Use action to return to the top left"
		Tutorial_Step.ENEMY:
			$UI/Themer/Control.visible = true
			$UI/Themer/C3/TutorialLabel.text = "Avoid this intruder!"
			spawn_enemy_at_location(Vector2(120,120) + $GridPanel.global_position,direction_dict["up"])
		Tutorial_Step.GROUP:
			$UI/Themer/C3/TutorialLabel.text = "Now begin your journey at the center" ##Group update
			pass
		Tutorial_Step.EXIT:
			current_mode = Mode.GAMEPLAY

func set_current_mode(given_mode: Mode):
	current_mode = given_mode
	match current_mode:
		Mode.GAMEPLAY:
			refresh_the_board()
		Mode.TUTORIAL:
			current_tutorial_step = Tutorial_Step.MOVE
			is_spawning_enemies = false
			reset_tether_point()
			$UI/Themer/QuoteLabel.visible = false
			$UI/Themer/Control.visible = false
			step_log.visible = false

func check_inputs() -> void:
	if Input.is_action_just_pressed("ui_down"):
		clear_step_log()
		attempt_move(direction_dict["down"])
	if Input.is_action_just_pressed("ui_up"):
		clear_step_log()
		attempt_move(direction_dict["up"])
	if Input.is_action_just_pressed("ui_right"):
		clear_step_log()
		attempt_move(direction_dict["right"])
	if Input.is_action_just_pressed("ui_left"):
		clear_step_log()
		attempt_move(direction_dict["left"])
	if Input.is_action_just_pressed("ui_accept"):
		clear_step_log()
		attempt_teleport_to_tether_point()
 



##Add fail conditions and whatever

func attempt_move(move_direction: Vector2): ##
	##Add stuff about communicating what's happening
	##Check if tile is occupied or something
	##control player and enemy?
	var attempted_move_position = player.global_position + (move_direction * distance_between_tile_centers)
	add_text_to_step_log("Attempt to go " + str(direction_dict.find_key(move_direction)))
	if is_position_in_grid(attempted_move_position):
		player.global_position = attempted_move_position
		add_text_to_step_log("You went " + str(direction_dict.find_key(move_direction)) + "!")
		end_turn()
	else:
		#Double check for secrets
		flash_the_grid()
		add_text_to_step_log("Too far from center")

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


func attempt_teleport_to_tether_point(): ##
	add_text_to_step_log("Attempt to teleport")
	if tether_point.global_position == player.global_position:
		##Check for tunnler secret
		add_text_to_step_log("Blocked by You :(")
	if is_enemy_at_position(tether_point.global_position):
		##Check for skywrath secret
		add_text_to_step_log("Blocked by Enemy :(")
	else:
		var where_to_teleport: Vector2
		where_to_teleport = tether_point.position
		tether_point.position = player.position
		player.position = where_to_teleport
		add_text_to_step_log("Succesful teleport!")
		end_turn()


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
	var current_tween = create_tween()
	current_tween.tween_property($GridPanel/FullGrid, "position", Vector2(63,60), 0.04)
	current_tween.tween_property($GridPanel/FullGrid, "position", Vector2(60,60), 0.04)


func end_turn():
	move_all_enemies()
	if is_player_on_an_enemy():
		kill_player()
	else:
		if is_spawning_enemies:
			var enemies_to_spawn = enemies_spawned_per_turn
#			if current_group == Group.GROUPLESS: #
#				enemies_to_spawn += 2
			spawn_amount_of_new_enemies(enemies_to_spawn) #Make it so that the player can choose
		present_turns_left_this_round -= 1
		present_turns_alive += 1
		self.rotation
	$UI/Themer/Control/TurnsAliveLabel.text = ("turns alive: " + str(present_turns_alive))
	$UI/Themer/Control/RoundCountdown.text = ("Turns left: " + str(present_turns_left_this_round))
	$UI/Themer/Control/ActionMisuse.text = ("Turns left without using action: " + str(present_turns_left_until_death_from_action_nonuse))
	if group_conditions_have_been_broken():
		add_text_to_step_log("Disconnected from group")
		add_text_to_step_log("You're alone")
		current_group = Group.GROUPLESS
	else:
		add_text_to_step_log("Next turn starts")

func is_enemy_at_position(given_position: Vector2) -> bool:
	for enemy in enemy_collection.get_children():
		if enemy.global_position == given_position:
			return true
	return false
	

func move_all_enemies():
	for enemy in enemy_collection.get_children():
		var movement_vector: Vector2
		if enemy.rotation_degrees == 0: #I KNOW I KNOW, I'll go through SOHCAHTOA when I'm not on a time deadline
			movement_vector = direction_dict["up"]
		if enemy.rotation_degrees == 90:
			movement_vector = direction_dict["right"]
		if enemy.rotation_degrees == 180:
			movement_vector = direction_dict["down"]
		if enemy.rotation_degrees == 270:
			movement_vector = direction_dict["left"]
		enemy.global_position += movement_vector * distance_between_tile_centers 
		if !is_position_in_grid(enemy.global_position):
			kill_enemy(enemy)

func is_player_on_an_enemy() -> bool:
	for enemy in enemy_collection.get_children():
		if player.global_position == enemy.global_position:
			return true
	return false

func kill_player():
	add_text_to_step_log("Your link to life has been severed")
	refresh_the_board()

func kill_enemy(given_enemy: Node2D):
	given_enemy.queue_free()

func spawn_amount_of_new_enemies(amount_of_enemies_to_spawn: int):
	where_latest_enemies_spawned = []
	var is_position_ok_to_spawn: bool = false
	var where_enemy_will_spawn: Vector2
	var enemies_spawned: int = 0
	while enemies_spawned != amount_of_enemies_to_spawn:
		is_position_ok_to_spawn = false
		while !is_position_ok_to_spawn: #This makes this terrifying but whatever
			var test_direction = get_random_direction_of_spawning_enemy()
			where_enemy_will_spawn = get_outer_tile_position_on_opposing_edge(test_direction)
			if where_enemy_will_spawn not in where_latest_enemies_spawned:
				spawn_enemy_at_location(where_enemy_will_spawn, test_direction)
				is_position_ok_to_spawn = true #This seems to be enterily broken but whatever
				enemies_spawned += 1

func get_random_direction_of_spawning_enemy() -> Vector2:
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
	var test_direction = get_random_direction_of_spawning_enemy()
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

func spawn_enemy_at_location(given_location: Vector2, given_aim_direction: Vector2):
	var new_enemy = spawnable_enemy.instantiate()
	enemy_collection.add_child(new_enemy)
	if given_aim_direction == direction_dict["right"]: #Idk match for some reason isnt working
		new_enemy.rotation_degrees = 90
	if given_aim_direction == direction_dict["down"]:
		new_enemy.rotation_degrees = 180
	if given_aim_direction == direction_dict["left"]:
		new_enemy.rotation_degrees = 270
	new_enemy.global_position = given_location
	if new_enemy.global_position == player.global_position:
		add_text_to_step_log("Wooooah! Enemy spawned on you")


#Ok so like I'm thinking of a step by step system where each step that's attempted
#Is slowly revealed which I have the tech for but whatever that's too slow


func clear_step_log():
	for written_label_step in step_log.get_children():
		written_label_step.queue_free()

func add_text_to_step_log(given_text: String):
	#oooh I can add colors or effects with RichText
	var new_label = Label.new()
	step_log.add_child(new_label)
	new_label.text = given_text


func group_conditions_have_been_broken() -> bool:
	#A lost fragment of mechanics and ideas. All it needs is some time
	match current_group:
		Group.GRIDWRATH:
			if player.global_position == $GridPanel/CentralTether.global_position:
				return true
		Group.TUNNELERS:
			if player.global_position == $GridPanel/CentralTether.global_position:
				return true
	return false
