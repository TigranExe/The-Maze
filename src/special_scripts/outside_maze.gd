extends Node2D

var current_player_input_scheme: InputScheme = InputScheme.MOUSE_KEYBOARD ###THis can be compartimentalized
enum InputScheme {
	MOUSE_KEYBOARD,
	CONTROLLER
}
var movement_vector: Vector2
var outside_character_speed: int = 200


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	check_for_new_player_inputs_to_move()
	move_outside_character_by_movement_vector(movement_vector)

func check_for_new_player_inputs_to_move():
	movement_vector = Vector2.ZERO
#	if current_player_input_scheme == InputScheme.CONTROLLER:
#		movement_vector = Vector2(
#		Input.get_action_strength("controller_move_right") - Input.get_action_strength("controller_move_left"),
#		Input.get_action_strength("controller_move_down") - Input.get_action_strength("controller_move_up")
#		).limit_length(1.0)
#		var forced_aiming_vector = Vector2(
#		Input.get_action_strength("controller_aim_right") - Input.get_action_strength("controller_aim_left"),
#		Input.get_action_strength("controller_aim_down") - Input.get_action_strength("controller_aim_up")
#		).limit_length(1.0)
	if current_player_input_scheme == InputScheme.MOUSE_KEYBOARD:#8d movement is possible...
		#movement_vector = Input.get_vector()
		if Input.is_action_pressed("ui_right"):
			movement_vector.x = 1.0
		if Input.is_action_pressed("ui_left"):
			movement_vector.x = -1.0
		if Input.is_action_pressed("ui_down"):
			movement_vector.y = 1.0
		if Input.is_action_pressed("ui_up"):
			movement_vector.y = -1.0
		movement_vector = movement_vector.normalized()
	pass

func move_outside_character_by_movement_vector(given_movement_vector: Vector2):
	$OutsideCharacter.velocity = given_movement_vector * outside_character_speed
	$OutsideCharacter.move_and_slide()
