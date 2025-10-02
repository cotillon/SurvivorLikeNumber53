class_name HitboxComponent
extends Area2D

var damage = 0

signal contact_with_hurtbox

func _ready() -> void:
	area_entered.connect(on_area_entered)


func on_area_entered(other_area: Area2D):

	#this should work to filter the area if pass is replaced with return but doesn't 
	if other_area != HurtboxComponent:
		pass
	contact_with_hurtbox.emit()


func disable_collision():
	$CollisionShape2D.disabled = true