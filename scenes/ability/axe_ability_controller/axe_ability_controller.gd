extends Node

var damage = 10

@export var axe_ability_scene: PackedScene

@onready var timer = $Timer
@onready var player = get_tree().get_first_node_in_group("player") as Node2D
@onready var foreground = get_tree().get_first_node_in_group("foreground_layer") as Node2D

func _ready() -> void:
	timer.timeout.connect(on_timer_timeout)



func on_timer_timeout():
	if player == null:
		return

	if foreground == null:
		return

	var axe_instance = axe_ability_scene.instantiate() as Node2D
	foreground.add_child(axe_instance)
	axe_instance.global_position = player.global_position
	axe_instance.hitbox_component.damage = damage
