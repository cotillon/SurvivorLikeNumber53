extends Node2D

const MAX_RADIUS = 100

var duration := 3

var proj_speed : float


@onready var hitbox_component = $HitboxComponent as HitboxComponent
@onready var player = get_tree().get_first_node_in_group("player") as Node2D

var base_rotation = Vector2.RIGHT

func _ready() -> void:

	base_rotation = Vector2.RIGHT.rotated(randf_range(0, TAU))

	var tween = create_tween()
	tween.tween_method(tween_method, 0.0, proj_speed, duration)
	tween.tween_callback(queue_free)


#this method rotates our axe around us according to the tween stats specified above
func tween_method(rotations: float):
	var percent = rotations / 2
	var current_radius = percent * MAX_RADIUS
	var current_direction = base_rotation.rotated(rotations * TAU)

	if player == null:
		return

	global_position = player.global_position + (current_direction * current_radius)
