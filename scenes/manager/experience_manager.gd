extends Node

signal experience_updated(current_experience: float, target_experience: float)
signal level_up(new_level: int)

#how much more experience we need per level
const TARGET_EXPERIENCE_GROWTH = 4

var current_experience = 0
var current_level = 1
var target_experience = 3


func _ready() -> void:
	GameEvents.experience_vial_collected.connect(on_experience_vial_collected)


#listens for our GameEvents to tell us we collected experience
func on_experience_vial_collected(number:float):
	increment_experience(number)


func increment_experience(number: float):
	current_experience = min(current_experience + number, target_experience)
	experience_updated.emit(current_experience, target_experience)
	if current_experience == target_experience:
		current_level += 1
		target_experience += (TARGET_EXPERIENCE_GROWTH * current_level)
		current_experience = 0
		experience_updated.emit(current_experience, target_experience)
		level_up.emit(current_level)
