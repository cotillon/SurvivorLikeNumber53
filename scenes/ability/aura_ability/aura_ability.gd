class_name AuraAbility
extends Node2D

@onready var hitbox_component: HitboxComponent = $%HitboxComponent
@onready var player = get_tree().get_first_node_in_group("player") as Node2D

func _process(delta: float) -> void:
	if player:
		global_position = player.global_position
