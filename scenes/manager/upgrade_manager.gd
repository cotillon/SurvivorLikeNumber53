extends Node

#@export var upgrade_pool: Array[AbilityUpgrade]
@export var experience_manager: Node
#this should be our upgrade screen
@export var upgrade_screen_scene: PackedScene

var current_upgrades = {}
var upgrade_pool: WeightedTable = WeightedTable.new()

var weapon_pool: WeightedTable = WeightedTable.new()

#surely there is a better way to do this

#base skills
var upgrade_sword = preload("res://resources/upgrades/sword.tres")
var upgrade_axe = preload("res://resources/upgrades/axe.tres")
var upgrade_aura = preload("res://resources/upgrades/aura.tres")
var upgrade_lightning = preload("res://resources/upgrades/lightning.tres")
var upgrade_fireball = preload("res://resources/upgrades/fireball.tres")

#skill upgrades
var upgrade_axe_damage = preload("res://resources/upgrades/axe_damage.tres")
var upgrade_axe_rate = preload("res://resources/upgrades/axe_rate.tres")
var upgrade_axe_proj_speed = preload("res://resources/upgrades/axe_proj_speed.tres")

var upgrade_sword_rate = preload("res://resources/upgrades/sword_rate.tres")
var upgrade_sword_damage = preload("res://resources/upgrades/sword_damage.tres")
var upgrade_sword_amount = preload("res://resources/upgrades/sword_amount.tres")
var upgrade_sword_pool_size = preload("res://resources/upgrades/sword_pool_size.tres")

var upgrade_aura_rate = preload("res://resources/upgrades/aura_rate.tres")
var upgrade_aura_damage = preload("res://resources/upgrades/aura_damage.tres")
var upgrade_aura_base_damage = preload("res://resources/upgrades/aura_base_damage.tres")
var upgrade_aura_size = preload("res://resources/upgrades/aura_size.tres")
var upgrade_aura_healing = preload("res://resources/upgrades/aura_healing.tres")

var upgrade_lightning_rate = preload("res://resources/upgrades/lightning_rate.tres")
var upgrade_lightning_damage = preload("res://resources/upgrades/lightning_damage.tres")
var upgrade_lightning_amount = preload("res://resources/upgrades/lightning_amount.tres")
var upgrade_lightning_strike_size = preload("res://resources/upgrades/lightning_strike_size.tres")

var upgrade_fireball_damage = preload("res://resources/upgrades/fireball_damage.tres")
var upgrade_fireball_base_damage = preload("res://resources/upgrades/fireball_base_damage.tres")
var upgrade_fireball_rate = preload("res://resources/upgrades/fireball_rate.tres")
var upgrade_fireball_split = preload("res://resources/upgrades/fireball_split.tres")

#player upgrades
var upgrade_player_speed = preload("res://resources/upgrades/player_speed.tres")

var counter := 2
var weapons_counter = 0

func _ready() -> void:
	#weapons
	weapon_pool.add_item(upgrade_sword, 10)
	weapon_pool.add_item(upgrade_axe, 10)
	weapon_pool.add_item(upgrade_aura, 10)
	weapon_pool.add_item(upgrade_lightning, 10)
	weapon_pool.add_item(upgrade_fireball, 10)

	#base upgrades with no picked weapons
	upgrade_pool.add_item(upgrade_player_speed, 5)

	experience_manager.level_up.connect(on_level_up)

	on_level_up()


#BUG SOFTLOCK UPON REACHING THE END OF THE UPGRADES LIST
func apply_upgrade(upgrade: AbilityUpgrade):

	var has_upgrade = current_upgrades.has(upgrade.id)
	if !has_upgrade:
		current_upgrades[upgrade.id] = {
			"resource": upgrade,
			"quantity": 1
		}
	else: current_upgrades[upgrade.id]["quantity"] +=1

	if upgrade.max_quantity > 0:
		var current_quantity = current_upgrades[upgrade.id]["quantity"]
		if current_quantity == upgrade.max_quantity:
			upgrade_pool.remove_item(upgrade)
			weapon_pool.remove_item(upgrade)

	update_upgrade_pool(upgrade)
	GameEvents.emit_ability_upgrade_added(upgrade, current_upgrades)


#use this function to determine when to allow certain upgrades to appear
func update_upgrade_pool(chosen_upgrade: AbilityUpgrade):

	match chosen_upgrade.id:
		upgrade_sword.id:
			upgrade_pool.add_item(upgrade_sword_rate, 10)
			upgrade_pool.add_item(upgrade_sword_damage, 10)
			upgrade_pool.add_item(upgrade_sword_amount, 5)
			upgrade_pool.add_item(upgrade_sword_pool_size, 10)
		upgrade_axe.id:
			upgrade_pool.add_item(upgrade_axe_damage, 10)
			upgrade_pool.add_item(upgrade_axe_rate, 10)
			upgrade_pool.add_item(upgrade_axe_proj_speed, 5)
		upgrade_aura.id:
			# upgrade_pool.add_item(upgrade_aura_damage, 10)
			upgrade_pool.add_item(upgrade_aura_rate, 10)
			upgrade_pool.add_item(upgrade_aura_size, 10)
			upgrade_pool.add_item(upgrade_aura_base_damage, 10)
			upgrade_pool.add_item(upgrade_aura_healing, 10)
		upgrade_lightning.id:
			upgrade_pool.add_item(upgrade_lightning_damage, 10)
			upgrade_pool.add_item(upgrade_lightning_rate, 10)
			upgrade_pool.add_item(upgrade_lightning_amount, 10)
			upgrade_pool.add_item(upgrade_lightning_strike_size, 10)
		upgrade_fireball.id:
			upgrade_pool.add_item(upgrade_fireball_damage, 10)
			upgrade_pool.add_item(upgrade_fireball_base_damage, 10)
			upgrade_pool.add_item(upgrade_fireball_rate, 10)
			upgrade_pool.add_item(upgrade_fireball_split, 10)



func pick_upgrades():
	var chosen_upgrades_array: Array[AbilityUpgrade] = []

	for i in 3:
		if upgrade_pool.items.size() == chosen_upgrades_array.size():
			break
		var chosen_upgrade = upgrade_pool.pick_item(chosen_upgrades_array)
		chosen_upgrades_array.append(chosen_upgrade)


	return chosen_upgrades_array


func pick_weapons():
	var chosen_weapons_array: Array = []

	for i in 3:
		if weapon_pool.items.size() == chosen_weapons_array.size():
			break
		var chosen_weapon = weapon_pool.pick_item(chosen_weapons_array)
		chosen_weapons_array.append(chosen_weapon)

	return chosen_weapons_array


func on_upgrade_selected(upgrade:AbilityUpgrade):
	apply_upgrade(upgrade)

#current_level: int
func on_level_up():

	counter += 1
	#instantiate our upgrade screen UI element, then call the function to display the cards
	var upgrade_screen_instance = upgrade_screen_scene.instantiate()
	add_child(upgrade_screen_instance)

	if (counter % 3) == 0 && (weapons_counter < 2):
		var chosen_weapons_array = pick_weapons()
		upgrade_screen_instance.set_ability_upgrades(chosen_weapons_array as Array)
		weapons_counter += 1


	else:
		var chosen_upgrades_array = pick_upgrades()
		upgrade_screen_instance.set_ability_upgrades(chosen_upgrades_array as Array[AbilityUpgrade])

	upgrade_screen_instance.upgrade_selected.connect(on_upgrade_selected)
