extends Camera2D

@export var follow_speed: int = 20

var target_position = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	make_current()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	acquire_target()
	#use .lerp() and this formula to smooth out camera movement
	global_position = global_position.lerp(target_position, 1.0 - exp(-delta * follow_speed))


#find the player and set our target_position to the player position
func acquire_target():
	var player_nodes = get_tree().get_nodes_in_group("player")
	if player_nodes.size() > 0:
		var player = player_nodes[0] as Node2D
		target_position = player.global_position
