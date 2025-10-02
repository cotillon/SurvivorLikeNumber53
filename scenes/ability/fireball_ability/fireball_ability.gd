class_name FireballAbility
extends CharacterBody2D

@onready var hitbox_component: HitboxComponent = $%HitboxComponent
@onready var velocity_component: VelocityComponent = $VelocityComponent
@onready var lifetime_timer: Timer = $LifetimeTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var number_of_forks := 0
var number_of_chains := 0
var number_of_pierces := 0


func _ready() -> void:
	hitbox_component.contact_with_hurtbox.connect(on_contact_with_hurtbox)
	lifetime_timer.timeout.connect(on_lifetime_timer_timeout)

func _process(delta: float) -> void:

	velocity_component.move(self)


func set_direction(direction: Vector2):
	velocity_component.apply_linear_velocity(direction)


func set_rotation_on_spawn(spawn_rotation: float):
	rotation = spawn_rotation


func fork():
	hitbox_component.disable_collision()
	var fireball_controller = get_tree().get_first_node_in_group("fireball_controller")
	await fireball_controller.fork_projectile(self, global_position, velocity)
	destroy_projectile()



func chain():
	pass


func pierce():
	pass
	# lifetime_timer.start()
	# await lifetime_timer.timeout
	# return


func destroy_projectile():
	Callable(queue_free).call_deferred()


func on_contact_with_hurtbox():
	
	while number_of_forks > 0 or number_of_chains > 0 or number_of_pierces > 0:

		if number_of_forks > 0:
			number_of_forks -= 1
			call_deferred("fork")
			return

		elif number_of_chains > 0:
			chain()
			number_of_chains -= 1
			return

		elif number_of_pierces > 0:
			pierce()
			number_of_pierces -= 1
			return

	destroy_projectile()


func on_lifetime_timer_timeout():
	destroy_projectile()
