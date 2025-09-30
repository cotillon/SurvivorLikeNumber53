extends Node

const MAX_RANGE = 250

@export var lightning_ability: PackedScene
@onready var player = get_tree().get_first_node_in_group("player") as Node2D

#the base damage of our ability
var base_damage = 5
#base wait time of our timer
var base_wait_time
#aura size
var base_radius_percent := 1.0
#number of attacks to spawn
var number_of_attacks := 3

#these should be adjusted based on future upgrades
var added_flat_damage = 0
var damage_percent_increase = 1.0

var initialized := false

var lightning_instance

func _ready():
	base_wait_time = $Timer.wait_time
	$Timer.timeout.connect(on_timer_timeout)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)


func on_timer_timeout():

	if player == null:
		return

	#get an array of the enemies, then filter out based on our MAX_RANGE
	var enemies = get_tree().get_nodes_in_group("enemies")
	enemies = enemies.filter(func(enemy: Node2D):
		return enemy.global_position.distance_squared_to(player.global_position) < pow(MAX_RANGE, 2)
	)
	#no enemies in range? do nothing
	if enemies.size() == 0:
		return

	# TEST CODE TEST CODE TEST CODE TEST CODE
	for attack in number_of_attacks:
	# TEST CODE TEST CODE TEST CODE TEST CODE

		#instantiate the sword and place it on the nearest enemy
		lightning_instance = lightning_ability.instantiate() as LightningAbility
		var foreground_layer = get_tree().get_first_node_in_group("foreground_layer")
		foreground_layer.add_child(lightning_instance)

		#assign our damage to the hitbox's damage component
		lightning_instance.hitbox_component.damage = calculate_damage()

	# TEST CODE TEST CODE TEST CODE TEST CODE
		if (enemies.size() - 1) >= attack:
			#spawn the sword on the enemy position
			lightning_instance.global_position = enemies[attack].global_position

			#rotate the sword to face the enemy
			#var enemy_direction = enemies[attack].global_position - lightning_instance.global_position
			#lightning_instance.rotation = enemy_direction.angle()


#applies our damage scaling formula and returns the result
func calculate_damage() -> float:
	var total_damage = (base_damage + added_flat_damage) * damage_percent_increase
	return total_damage


#listen for the game event upgrade added, then filter for the sword upgrade
func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):

	match upgrade.id:
		"lightning_rate":
			var percent_reduction = current_upgrades["lightning_rate"]["quantity"] * .15
			$Timer.wait_time = base_wait_time * (1 - percent_reduction)
			$Timer.start()
		"lightning_damage":
			damage_percent_increase = 1 + (current_upgrades["lightning_damage"]["quantity"] * .15)
		"lightning_amount":
			number_of_attacks += 2
