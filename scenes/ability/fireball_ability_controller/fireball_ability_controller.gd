extends Node

@export var fireball_ability: PackedScene

@onready var player = get_tree().get_first_node_in_group("player") as Node2D

var MAX_RANGE = 350
var speed = 500
#the base damage of our ability
var base_damage = 8
#base wait time of our timer
var base_wait_time
#aura size
var base_radius_percent := 1.0

#these should be adjusted based on future upgrades
var added_flat_damage = 0
var damage_percent_increase = 1.0

var number_of_attacks := 1


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

	#get an array of the enemies, then filter out based on our MAX_RANGE
	var enemies = get_tree().get_nodes_in_group("enemies")
	enemies = enemies.filter(func(enemy: Node2D):
		return enemy.global_position.distance_squared_to(player.global_position) < pow(MAX_RANGE, 2)
	)
	#no enemies in range? do nothing
	if enemies.size() == 0:
		return

	#sort the array based on distance to player
	enemies.sort_custom(func (a: Node2D, b: Node2D):
		var a_distance = a.global_position.distance_squared_to(player.global_position)
		var b_distance = b.global_position.distance_squared_to(player.global_position)
		return a_distance < b_distance
	)

	for attack in number_of_attacks:

		var fireball_instance = fireball_ability.instantiate() as FireballAbility
		var foreground_layer = get_tree().get_first_node_in_group("foreground_layer")
		foreground_layer.add_child(fireball_instance)

		fireball_instance.hitbox_component.damage = calculate_damage()

		var start_position = player.global_position
		fireball_instance.global_position = start_position
		var direction_from_start = enemies[0].global_position - start_position
		var target_rotation = direction_from_start.angle()
		fireball_instance.set_rotation_on_spawn(target_rotation)
		fireball_instance.set_direction(player.global_position.direction_to(enemies[attack].global_position))


		# var bullet_velocity = player.global_position.direction_to(enemies[attack].global_position) * speed
		# fireball_instance.translate(bullet_velocity)

		# var tween = create_tween()
		# # 0.8 in this function represents time in seconds for the proj to travel
		# tween.tween_method(tween_move_projectile.bind(start_position, enemies[attack].global_position, fireball_instance), 0.0, 1.0, 0.8)
		# tween.tween_callback(fireball_instance.queue_free)



# func tween_move_projectile(percent: float, start_position: Vector2, enemy_position, fireball_instance):
# 	if player == null:
# 		return

# 	fireball_instance.global_position = start_position.lerp(enemy_position, percent)
# 	var direction_from_start = enemy_position - start_position
# 	var target_rotation = direction_from_start.angle()
# 	fireball_instance.rotation = target_rotation




func update_values():
	pass

#listen for the game event upgrade added, then filter for the sword upgrade
func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):

	match upgrade.id:
		"aura_rate":
			var percent_reduction = current_upgrades["aura_rate"]["quantity"] * .25
			$Timer.wait_time = base_wait_time * (1 - percent_reduction)
			$Timer.start()
		"aura_damage":
			damage_percent_increase = 1 + (current_upgrades["aura_damage"]["quantity"] * .25)
		"aura_base_damage":
			base_damage += 1.5
		"aura_size":
			base_radius_percent = 1 + (current_upgrades["aura_size"]["quantity"] * .50)

	update_values()
