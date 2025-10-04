extends Node

#the base damage of our ability
var BASE_DAMAGE = 10
#base wait time of our timer
var base_wait_time
#speed of the axe spinning around the player
var proj_speed := 2.0

#these should be adjusted based on future upgrades
var added_flat_damage = 0
var damage_percent_increase = 1.0


@export var axe_ability_scene: PackedScene

@onready var timer = $Timer
@onready var player = get_tree().get_first_node_in_group("player") as Node2D
@onready var foreground = get_tree().get_first_node_in_group("foreground_layer") as Node2D

func _ready() -> void:
	base_wait_time = timer.wait_time
	timer.timeout.connect(on_timer_timeout)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)


#applies our damage scaling formula and returns the result
func calculate_damage() -> float:
	var total_damage = (BASE_DAMAGE + added_flat_damage) * damage_percent_increase
	return total_damage


func on_timer_timeout():
	if player == null:
		return
	if foreground == null:
		return
	var axe_instance = axe_ability_scene.instantiate() as Node2D
	axe_instance.proj_speed = proj_speed
	foreground.add_child(axe_instance)
	axe_instance.global_position = player.global_position
	axe_instance.hitbox_component.damage = calculate_damage()
	


#listen for the game event upgrade added, then filter for the sword upgrade
func on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	match upgrade.id:
		"axe_rate":
			var percent_reduction = current_upgrades["axe_rate"]["quantity"] * .20
			timer.wait_time = base_wait_time * (1 - percent_reduction)
			timer.start()
		"axe_damage":
			damage_percent_increase = 1 + (current_upgrades["axe_damage"]["quantity"] * .20)
		"axe_proj_speed":
			proj_speed = 2 + (current_upgrades["axe_proj_speed"]["quantity"] * .25)
