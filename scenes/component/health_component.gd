class_name HealthComponent
extends Node

signal died(owner)
signal health_changed(value: String)

@export var max_health: float = 10
@export var health_regen: float = 0
@onready var health_regen_timer: Timer = $HealthRegenTimer
var current_health


func _ready():
	health_regen_timer.timeout.connect(on_health_regen_timer_timeout)
	current_health = max_health



func damage(damage_amount: float):
	current_health = max(current_health - damage_amount, 0)
	health_changed.emit("damage")
	Callable(check_death).call_deferred()


func heal(heal_amount: float):
	current_health = min(current_health + heal_amount, max_health)
	health_changed.emit("heal")


func get_health_percent():
	if max_health <= 0:
		return 0
	return  min(current_health / max_health, 1)


func check_death():
	if current_health == 0:
		died.emit(owner)
		GameEvents.emit_unit_died(owner)
		owner.queue_free()


func on_health_regen_timer_timeout():
	if health_regen > 0:
		heal(health_regen)
