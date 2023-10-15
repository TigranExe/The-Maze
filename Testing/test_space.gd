extends Node2D


# Called when the node enters the scene tree for the first time.
enum TextFileLineLookingFor {
		CODES,
		ROOMROW,
		CIRCUITROW
	}
var current_TextFileLineLookingFor: TextFileLineLookingFor = TextFileLineLookingFor.CODES


var room_dictionary: Dictionary = {
	
}
var circuit_dictionary: Dictionary = {
	
}
var file_writing_legend: Dictionary = {
	"room_code" :  ">>R",
	"circuit_code" : ">>C"
}

var first_letter_of_in_game_element_dictionary: Array = ["W", "C"] ###Hahaha not dicitonaries at the moment
var first_letter_of_in_game_effect_dictionary: Array = ["V", "E", "M"]

func _ready() -> void:
	read_experience_text_file("res://FileExperimentation/ShowcaseExperience.txt")
	#Verify and raise errors
	#transmit info


func read_experience_text_file(given_experience_text_file_path: String):
	var file = FileAccess.open(given_experience_text_file_path, FileAccess.READ)
	var current_callable_that_edits_stored_data: Callable ###Maybe I can use a callable instead of stored dictionary values?
	var current_dictionary_key: String
	var current_dictionary_contents: Array
	var amount_of_lines_to_read_and_store: int = 0
	var content = file.get_as_text().split("\n")
	file.close()
	var total_lines_in_file: int = content.size()
	var current_line: int = 1
	var line_read: bool = false
	while current_line < total_lines_in_file:
		var line: String = content[current_line - 1]
		line_read = false
		#print(line)
		if current_TextFileLineLookingFor == TextFileLineLookingFor.CODES and !line_read:
			if line.begins_with(file_writing_legend["room_code"]):
				###next5 lines should be roomrow codes
				var what_room_code: String = line.substr(2,-1)
				room_dictionary[what_room_code] = []
				current_dictionary_key = what_room_code
				current_TextFileLineLookingFor = TextFileLineLookingFor.ROOMROW
				amount_of_lines_to_read_and_store = 5
				line_read = true
				pass
			elif line.begins_with(file_writing_legend["circuit_code"]):
				###Next line should contain information on the circuit
				var what_circuit_code: String = line.substr(2,-1)
				circuit_dictionary[what_circuit_code] = []
				current_dictionary_key = what_circuit_code
				current_TextFileLineLookingFor = TextFileLineLookingFor.CIRCUITROW
				amount_of_lines_to_read_and_store = 1
				line_read = true
				pass
			else:
				line_read = true
		if current_TextFileLineLookingFor == TextFileLineLookingFor.ROOMROW and !line_read:
			####Read the roomrow and reduce the next lines until it's 0 and then go to CODES
			var every_tile_in_row = line.split("],")
			for tile in every_tile_in_row:
				room_dictionary[current_dictionary_key].append(tile)
			amount_of_lines_to_read_and_store -= 1
			if amount_of_lines_to_read_and_store == 0:
				current_TextFileLineLookingFor = TextFileLineLookingFor.CODES
				print(room_dictionary[current_dictionary_key])
			line_read = true
			pass
		if current_TextFileLineLookingFor == TextFileLineLookingFor.CIRCUITROW and !line_read:
			####Read the roomrow and reduce the next lines until it's 0 and then go to CODES
			var every_effect_in_order = line.split("],")
			for effect in every_effect_in_order:
				circuit_dictionary[current_dictionary_key].append(effect)
			amount_of_lines_to_read_and_store -= 1
			if amount_of_lines_to_read_and_store == 0:
				current_TextFileLineLookingFor = TextFileLineLookingFor.CODES
				print(circuit_dictionary[current_dictionary_key])
			line_read = true
			pass
		
		if line_read:
			current_line += 1

func are_dictionaries_valid() -> bool :
	return true

func verify_circuit_dictionary() -> bool :
	for circuit in circuit_dictionary:
		for effect in circuit:
			var effect_first_letter = effect.substr(0,1)
			if effect_first_letter not in first_letter_of_in_game_effect_dictionary:
				return false
	return true
		

func verify_room_dictionary() -> bool :
	for room in room_dictionary:
		var amount_of_rooms = 0
		
		for tile in room:
			var element_first_letter = tile.substr(0,1)
			if element_first_letter not in first_letter_of_in_game_element_dictionary:
				return false
			if element_first_letter not in first_letter_of_in_game_effect_dictionary:
				return false
	return true
