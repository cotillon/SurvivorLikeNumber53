extends Node

@export var fireball_ability: PackedScene
@onready var player = get_tree().get_first_node_in_group("player") as Node2D

var MAX_RANGE = 350
var speed = 175
#the base damage of our ability
var base_damage = 5
#base wait time of our timer
var base_wait_time
#size
var base_radius_percent := 1.0
#the amount of projectiles to spawn from a fork
var number_of_forked_projectiles := 1
#these should be adjusted based on future upgrades
var added_flat_damage = 0
var damage_percent_increase = 1.0

var number_of_attacks := 1


#! TEST CODE
var enemies: Array = []

var forks := 0
var chains := 0
var pierces := 0

#! TEST CODE


func _ready() -> void:
	if player == null:
		return


	base_wait_time = $Timer.wait_time
	$Timer.timeout.connect(on_timer_timeout)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)


func _process(delta: float) -> void:
	pass


	#applies our damage scaling formula and returns the result
func calculate_damage() -> float:
	var total_damage = (base_damage + added_flat_damage) * damage_percent_increase
	return total_damage


func on_timer_timeout():
	#identify the player, then check if it exists
	if player == null:
		return

	enemies = get_and_sort_enemies()

	if enemies.size() == 0:
		return

	for attack in number_of_attacks:
		var fireball_instance = spawn_projectile(forks, chains, pierces)
		position_and_aim_projectile(fireball_instance, attack)



func get_and_sort_enemies():
	#get an array of the enemies, then filter out based on our MAX_RANGE
	var fenemies = get_tree().get_nodes_in_group("enemies")
	fenemies = fenemies.filter(func(enemy: Node2D):
		return enemy.global_position.distance_squared_to(player.global_position) < pow(MAX_RANGE, 2)
	)
	#no enemies in range? return an empty array
	if fenemies.size() == 0:
		var empty_array = []

		return empty_array

	#sort the array based on distance to player
	fenemies.sort_custom(func (a: Node2D, b: Node2D):
		var a_distance = a.global_position.distance_squared_to(player.global_position)
		var b_distance = b.global_position.distance_squared_to(player.global_position)
		return a_distance < b_distance
	)


	return fenemies


func spawn_projectile(number_of_forks: int, number_of_chains: int, number_of_pierces: int):
	if enemies.size() <= 0:
		return

	var fireball_instance = fireball_ability.instantiate() as FireballAbility

	var foreground_layer = get_tree().get_first_node_in_group("foreground_layer")
	foreground_layer.add_child(fireball_instance)

	fireball_instance.velocity_component.max_speed = speed
	fireball_instance.hitbox_component.damage = calculate_damage()

	#! TODO
	fireball_instance.number_of_forks = number_of_forks
	fireball_instance.number_of_chains = number_of_chains
	fireball_instance.number_of_pierces = number_of_pierces

	return fireball_instance


func position_and_aim_projectile(fireball_instance: FireballAbility, attack: int):


	if (enemies.size() - 1) >= attack:
		var start_position = player.global_position
		fireball_instance.global_position = start_position

		var direction_from_start = enemies[attack].global_position - start_position
		var target_rotation = direction_from_start.angle()
		fireball_instance.set_rotation_on_spawn(target_rotation)
		fireball_instance.set_direction(player.global_position.direction_to(enemies[attack].global_position))


#! TODO, this shits fucked yo
func fork_projectile(fireball_instance: FireballAbility, prev_position: Vector2, prev_velocity):

	enemies = get_and_sort_enemies()

	for projectile in number_of_forked_projectiles:

		if enemies.size() <= projectile:
			return

		# var forked_fireball = fireball_instance.duplicate(true)
		var forked_fireball = fireball_ability.instantiate() as FireballAbility

		forked_fireball.number_of_forks = fireball_instance.number_of_forks
		forked_fireball.number_of_chains = fireball_instance.number_of_chains
		forked_fireball.number_of_pierces = fireball_instance.number_of_pierces

		var foreground_layer = get_tree().get_first_node_in_group("foreground_layer")
		foreground_layer.add_child(forked_fireball)

		var direction_from_start = enemies[projectile].global_position - prev_position

		# forked_fireball.rotate(PI/rotation_degrees)
		# rotation_degrees = -rotation_degrees

		#! un-fuck this projectile split behavior
		forked_fireball.global_position = prev_position
		# var target_rotation = direction_from_start.angle()
		var direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
		var target_rotation = direction.angle()
		forked_fireball.set_rotation_on_spawn(target_rotation)
		forked_fireball.velocity_component.max_speed = speed
		forked_fireball.set_direction(direction.normalized())
		# forked_fireball.set_direction(prev_position.direction_to(enemies[projectile].global_position))


		forked_fireball.animation_player.play("fork")
		forked_fireball.hitbox_component.damage = calculate_damage()

		enemies.remove_at(projectile)



func update_values():
	pass



#listen for the game event upgrade added, then filter for the sword upgrade
func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):

	match upgrade.id:
		"fireball_rate":
			var percent_reduction = current_upgrades["fireball_rate"]["quantity"] * .15
			$Timer.wait_time = base_wait_time * (1 - percent_reduction)
			$Timer.start()
		"fireball_damage":
			damage_percent_increase = 1 + (current_upgrades["fireball_damage"]["quantity"] * .25)
		"fireball_base_damage":
			base_damage += 1.5
		"fireball_split":
			forks += 1
			number_of_forked_projectiles += 1
