class_name HitboxComponent
extends Area2D

var damage = 0

signal contact_with_hurtbox


func area_entered(other_area: Area2D):
	print_debug("contact with hurtbox.emit")
	if other_area != HurtboxComponent:
		return
	
	
	contact_with_hurtbox.emit()