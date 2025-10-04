class_name SwordAbility
extends Node2D

@onready var hitbox_component: HitboxComponent = $HitboxComponent

@export var blood_pool_scene: PackedScene


var leave_blood_pool := true
var pool_spawned := false

var blood_pool_damage: float
var blood_pool_radius: float


func _ready() -> void:
	hitbox_component.contact_with_hurtbox.connect(on_contact_with_hurtbox)



func spawn_blood_pool():
	print_debug("spawning blood pool")
	var blood_pool_instance = blood_pool_scene.instantiate()
	var foreground_layer = get_tree().get_first_node_in_group("foreground_layer")
	foreground_layer.add_child(blood_pool_instance)
	blood_pool_instance.global_position = global_position

	blood_pool_instance.base_damage = blood_pool_damage
	blood_pool_instance.pool_size.scale = Vector2.ONE * blood_pool_radius



func on_contact_with_hurtbox():
	print_debug("contact made")

	if !leave_blood_pool:
		return

	if !pool_spawned:
		Callable(spawn_blood_pool).call_deferred()
		pool_spawned = true
