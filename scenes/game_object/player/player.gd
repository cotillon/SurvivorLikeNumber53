extends CharacterBody2D


#our iframes
@onready var damage_interval_timer = $DamageIntervalTimer
@onready var health_component = $HealthComponent
@onready var health_bar = $HealthBar
@onready var abilities = $Abilities
@onready var visuals = $Visuals
@onready var velocity_component = $VelocityComponent
@onready var animated_sprite_2d: AnimatedSprite2D = $Visuals/AnimatedSprite2D
@onready var pickup_collision_shape_2d: CollisionShape2D = %PickupCollisionShape2D


#the total damage we should be taking according to how many enemies
#are colliding with player and their respective damages
var taking_damage_bucket = 0

var base_speed = 0

func _ready() -> void:
	base_speed = velocity_component.max_speed

	$CollisionArea2D.body_entered.connect(on_body_entered)
	$CollisionArea2D.body_exited.connect(on_body_exited)
	damage_interval_timer.timeout.connect(on_damage_interval_timer_timeout)
	health_component.health_changed.connect(on_health_changed)
	GameEvents.ability_upgrade_added.connect(on_ability_upgrade_added)
	update_health_display()



func _process(delta: float) -> void:
	var movement_vector = get_movement_vector()
	var direction = movement_vector.normalized()

	velocity_component.accelerate_in_direction(direction)
	velocity_component.move(self)
	animate_and_flip(movement_vector)


#returns a vector with our desired x/y movement
func get_movement_vector():
	var x_movement = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var y_movement = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	return Vector2(x_movement, y_movement)


#are we colliding? deal the appropriate amount of damage
func check_deal_damage():
	if taking_damage_bucket == 0 || !damage_interval_timer.is_stopped():
		return

	health_component.damage(taking_damage_bucket)
	damage_interval_timer.start()



func update_health_display():
	health_bar.value = health_component.get_health_percent()


func animate_and_flip(movement_vector):
		#animate the entity while moving
	if movement_vector.x != 0 || movement_vector.y != 0:
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")

	#flip our player based on direction
	var move_sign = sign(movement_vector.x)
	if move_sign != 0:
		visuals.scale = Vector2(move_sign, 1)



func on_body_entered(other_body: Node2D):
	taking_damage_bucket += other_body.DAMAGE
	check_deal_damage()


func on_body_exited(other_body: Node2D):
	taking_damage_bucket -= other_body.DAMAGE


func on_damage_interval_timer_timeout():
	check_deal_damage()


func on_health_changed(value: String):

	if value == "damage":
		GameEvents.emit_player_damaged()
		$RandomSteamPlayer2DComponent.play_random()
	elif value == "heal":
		pass
	
	update_health_display()
	


func on_ability_upgrade_added(ability_upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	if ability_upgrade is Ability:
		var ability = ability_upgrade as Ability
		abilities.add_child(ability.ability_controller_scene.instantiate())
	elif ability_upgrade.id == "player_speed":
		velocity_component.max_speed = base_speed + (base_speed * current_upgrades["player_speed"]["quantity"] * 0.2)
