extends Node

#connects to our health component and experience vial scenes
#listens for the on_died signal to roll to drop a vial


@export_range(0, 1) var drop_percent: float = 0.8
@export var health_component: HealthComponent
@export var vial_scene: PackedScene


func _ready():
	(health_component as HealthComponent).died.connect(on_died)


func on_died():
	var adjusted_drop_percent = drop_percent
	var experince_gain_upgrade_count = MetaProgression.get_upgrade_count("experience_gain")
	if experince_gain_upgrade_count > 0:
		adjusted_drop_percent += 0.1

	if randf() > adjusted_drop_percent:
		return

	if vial_scene == null:
		return

	if not owner is Node2D:
		return

	var spawn_position = (owner as Node2D).global_position
	var vial_instance = vial_scene.instantiate() as Node2D

	var entities_layer = get_tree().get_first_node_in_group("entities_layer")
	entities_layer.add_child(vial_instance)
	vial_instance.global_position = spawn_position
