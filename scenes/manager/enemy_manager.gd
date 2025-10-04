extends Node

const SPAWN_RADIUS = 375

@export var basic_enemy_scene: PackedScene
@export var hellhound_enemy_scene: PackedScene
@export var eye_demon_enemy_scene: PackedScene
@export var arena_time_manager: Node

@onready var timer = $Timer

var base_spawn_time = 0
var enemy_table = WeightedTable.new()
var number_to_spawn := 1

var total_enemies : Array = []

func _ready() -> void:
	enemy_table.add_item(basic_enemy_scene, 10)
	base_spawn_time = timer.wait_time

	timer.timeout.connect(on_timer_timeout)
	arena_time_manager.arena_difficulty_increased.connect(on_arena_difficulty_increased)
	GameEvents.unit_died.connect(on_unit_died)


#gets a valid spawn position, taking walls into account
func get_spawn_position():

	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return Vector2.ZERO

	#initialize our spawn position and direction
	var spawn_position = Vector2.ZERO
	var random_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))

	#this loop checks the spawn position against a raycast query to determine if it collides with a wall
	#if it does not collide, the loop stops and that spawn position is taken
	for i in 4:
		spawn_position = player.global_position + (random_direction * SPAWN_RADIUS)
		#prevent the enemy from spawning in a wall
		var additional_check_offset = random_direction * 20

		var query_parameters = PhysicsRayQueryParameters2D\
		.create(player.global_position, spawn_position + additional_check_offset, 1)
		var result = get_tree().root.world_2d.direct_space_state.intersect_ray(query_parameters)

		if result.is_empty():
			break
		else:
			random_direction = random_direction.rotated(deg_to_rad(90))

	return spawn_position


func on_timer_timeout():
	timer.start()

	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return

	if total_enemies.size() > 250:
		return

	for i in number_to_spawn:
		var enemy_scene = enemy_table.pick_item()
		var enemy = enemy_scene.instantiate() as Node2D

		total_enemies.append(enemy)

		var enemies_layer = get_tree().get_first_node_in_group("enemies_layer")
		enemies_layer.add_child(enemy)
		enemy.global_position = get_spawn_position()


#arena difficulty increments by 1 every 5 seconds
func on_arena_difficulty_increased(arena_difficulty: int):

	#? this affects how often enemies spawn
	var time_off = (0.1 / 7) * arena_difficulty
	time_off = min(time_off, 0.9)
	timer.wait_time = base_spawn_time - time_off

	#TODO TODO TODO
	if arena_difficulty == 18:
		enemy_table.add_item(hellhound_enemy_scene, 5)
	elif arena_difficulty == 33:
		enemy_table.remove_item(basic_enemy_scene)
		enemy_table.add_item(eye_demon_enemy_scene, 5)

	#TODO TODO TODO
	if (arena_difficulty % 3) == 0:
		number_to_spawn += 1


func on_unit_died(enemy):
	total_enemies.erase(enemy)
