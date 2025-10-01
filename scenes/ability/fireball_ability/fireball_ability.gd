class_name FireballAbility
extends CharacterBody2D

@onready var hitbox_component: HitboxComponent = $%HitboxComponent
@onready var velocity_component: VelocityComponent = $VelocityComponent

var number_of_forks := 0
var number_of_chains := 0
var number_of_pierces := 0


func _ready() -> void:
	hitbox_component.contact_with_hurtbox.connect(on_contact_with_hurtbox)


func _process(delta: float) -> void:

	velocity_component.move(self)


func set_direction(direction: Vector2):
	velocity_component.apply_linear_velocity(direction)


func set_rotation_on_spawn(spawn_rotation: float):
	rotation = spawn_rotation


func fork():
	pass


func chain():
	pass


func pierce():
	pass


func destroy_projectile():
	Callable(queue_free).call_deferred()


func on_contact_with_hurtbox():
	print_debug("contact made")

	while number_of_forks > 0 or number_of_chains > 0 or number_of_pierces > 0:

		if number_of_forks > 0:
			fork()
			number_of_forks -= 1
			continue
		elif number_of_chains > 0:
			chain()
			number_of_chains -= 1
			continue
		elif number_of_pierces > 0:
			pierce()
			number_of_pierces -= 1
			continue

	destroy_projectile()
