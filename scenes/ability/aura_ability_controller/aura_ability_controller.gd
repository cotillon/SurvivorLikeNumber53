extends Node

@export var aura_ability: PackedScene

@onready var player = get_tree().get_first_node_in_group("player") as Node2D

#the base damage of our ability
var base_damage = 3.5
#base wait time of our timer
var base_wait_time
#aura size
var base_radius_percent := 1.0

#these should be adjusted based on future upgrades
var added_flat_damage = 0
var damage_percent_increase = 1.0

var initialized := false

var aura_instance

func _ready():
	if player == null:
		return

	base_wait_time = $Timer.wait_time
	$Timer.timeout.connect(on_timer_timeout)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)

	aura_instance = aura_ability.instantiate()
	var entities_layer = get_tree().get_first_node_in_group("entities_layer")
	entities_layer.add_child.call_deferred(aura_instance)


func _process(delta: float) -> void:

	#workaround since we can't do this in the ready method
	if initialized == true:
		return
	update_values()
	initialized = true


#applies our damage scaling formula and returns the result
func calculate_damage() -> float:
	var total_damage = (base_damage + added_flat_damage) * damage_percent_increase
	return total_damage


func update_values():
	aura_instance.hitbox_component.damage = calculate_damage()
	aura_instance.get_node("AuraSize").scale = Vector2.ONE * base_radius_percent


func on_timer_timeout():
	#identify the player, then check if it exists
	if player == null:
		return
	aura_instance.hitbox_component.monitoring = false
	aura_instance.hitbox_component.monitoring = true


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
