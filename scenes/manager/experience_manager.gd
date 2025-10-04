extends Node

signal experience_updated(current_experience: float, target_experience: float)
signal level_up()
# signal sorting_complete

#how much more experience we need per level
const TARGET_EXPERIENCE_GROWTH = 3

@onready var timer = $Timer

var experience_locations: Array[Node2D] = []

# var consolidate_range := 1000

var current_experience = 0
var current_level = 1
var target_experience = 3


func _ready() -> void:
	GameEvents.experience_vial_collected.connect(on_experience_vial_collected)
	GameEvents.experience_dropped.connect(on_experience_dropped)

	timer.timeout.connect(on_timer_timeout)


#listens for our GameEvents to tell us we collected experience
func on_experience_vial_collected(experience: Node2D):
	increment_experience(experience)


func increment_experience(experience: Node2D):
	current_experience = min(current_experience + experience.experience_tier, target_experience)
	experience_updated.emit(current_experience, target_experience)

	var target_for_erasure = experience_locations.find(experience)
	erase_from_array(target_for_erasure)


	if current_experience == target_experience:
		current_level += 1
		target_experience += (TARGET_EXPERIENCE_GROWTH * current_level)
		current_experience = 0
		experience_updated.emit(current_experience, target_experience)
		level_up.emit()


func erase_from_array(target_for_erasure):
	# await sorting_complete
	if experience_locations.size() < 1:
		experience_locations.remove_at(target_for_erasure)

func on_timer_timeout():
	# GameEvents.emit_experience_cleanup()
	# sort_and_cleanup()
	pass


func on_experience_dropped(location):

	if experience_locations.size() > 650:
		GameEvents.clamp_experience_drops = true
	
	if experience_locations.size() < 620:
		experience_locations.append(location)
		GameEvents.clamp_experience_drops = false


"""
func sort_and_cleanup():
	experience_locations.sort()
	print_debug("sorting started")

	if experience_locations.size() <= 2:
		return

	for r in experience_locations.size():
		for i in 2:
			if experience_locations.size() < 3:
				print_debug("early exit")
				return

			if (experience_locations[i].global_position - experience_locations[i - 1].global_position) < (Vector2.ONE * consolidate_range):
				print_debug("cleanup!")
				experience_locations[i].set_tier(experience_locations[i].experience_tier + experience_locations[i - 1].experience_tier)
				experience_locations[i - 1].queue_free()
				experience_locations.remove_at(i)
				experience_locations.remove_at(i - 1)

	print_debug("sorting complete")
	sorting_complete.emit()

	"""
