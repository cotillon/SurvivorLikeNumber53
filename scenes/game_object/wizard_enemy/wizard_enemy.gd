extends CharacterBody2D


#this is accessed by the player script, and dictates how much damage this unit does per tick
#while colliding with the player
@export var DAMAGE: float = 2

@onready var visuals: Node2D = $Visuals
@onready var velocity_component: VelocityComponent = $VelocityComponent

var is_moving = true


func _ready() -> void:
	$HurtboxComponent.hit.connect(on_hit)


func _process(_delta: float) -> void:
	if is_moving:
		velocity_component.accelerate_to_player()
	else:
		velocity_component.decelerate()

	velocity_component.move(self)

	animate_and_flip()


#flip our unit based on its direction
func animate_and_flip():
	var move_sign = sign(velocity.x)
	if move_sign != 0:
		visuals.scale = Vector2(move_sign, 1)

func set_is_moving(moving: bool):
	is_moving = moving


func on_hit():
	$HitRandomAudioPlayerComponent.play_random()
