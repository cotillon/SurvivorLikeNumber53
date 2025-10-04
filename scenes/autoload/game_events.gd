extends Node

signal experience_vial_collected(experience: Node2D)
signal ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary)
signal player_damaged
signal experience_cleanup
signal experience_dropped
signal unit_died(unit: Node2D)


var damage_numbers_on := true

var clamp_experience_drops := false


func emit_experience_vial_collected(experience: Node2D):
	experience_vial_collected.emit(experience)


func emit_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	ability_upgrade_added.emit(upgrade, current_upgrades)


func emit_player_damaged():
	player_damaged.emit()


func emit_experience_cleanup():
	experience_cleanup.emit()


func emit_experience_dropped(experience_instance: Node2D):
	experience_dropped.emit(experience_instance)


func emit_unit_died(unit):
	if unit is Player:
		return
	unit_died.emit(unit)