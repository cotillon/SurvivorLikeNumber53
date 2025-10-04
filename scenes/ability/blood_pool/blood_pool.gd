extends Node2D


@onready var pool_size: Node2D = %PoolSize
@onready var hitbox_component: HitboxComponent = %HitboxComponent

var base_damage
var initialized = false

func _ready() -> void:
	$LifetimeTimer.timeout.connect(on_lifetime_timer_timeout)
	$TickTimer.timeout.connect(on_tick_timer_timeout)


func _process(delta):
	if initialized:
		return
	else:
		hitbox_component.damage = base_damage
		initialized = true



func tick_damage():
	hitbox_component.monitoring = false
	hitbox_component.monitoring = true


func on_tick_timer_timeout():
	Callable(tick_damage).call_deferred()


func on_lifetime_timer_timeout():
	Callable(queue_free).call_deferred()
