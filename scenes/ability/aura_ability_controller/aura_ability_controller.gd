extends Node

const MAX_RANGE = 150

@export var aura_ability: PackedScene

@onready var player = get_tree().get_first_node_in_group("player") as Node2D

#the base damage of our ability
var BASE_DAMAGE = 5
#base wait time of our timer
var base_wait_time


#these should be adjusted based on future upgrades
var added_flat_damage = 0
var damage_percent_increase = 1.0

var exists := false

var aura_instance

func _ready():
	if player == null:
		return

	base_wait_time = $Timer.wait_time
	$Timer.timeout.connect(on_timer_timeout)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)



func _process(delta: float) -> void:

	if exists == false:
		aura_instance = aura_ability.instantiate()
		var foreground_layer = get_tree().get_first_node_in_group("foreground_layer")
		foreground_layer.add_child(aura_instance)
		exists = true

	aura_instance.hitbox_component.damage = calculate_damage()
	aura_instance.global_position = player.global_position


func on_timer_timeout():
	#identify the player, then check if it exists
	if player == null:
		return


#applies our damage scaling formula and returns the result
func calculate_damage() -> float:
	var total_damage = (BASE_DAMAGE + added_flat_damage) * damage_percent_increase
	return total_damage


#listen for the game event upgrade added, then filter for the sword upgrade
func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):

	match upgrade.id:
		"sword_rate":
			var percent_reduction = current_upgrades["sword_rate"]["quantity"] * .1
			$Timer.wait_time = base_wait_time * (1 - percent_reduction)
			$Timer.start()
		"sword_damage":
			damage_percent_increase = 1 + (current_upgrades["sword_damage"]["quantity"] * .15)
