extends Node2D


func _ready() -> void:
	pass



func start(text: String):
	$Label.text = text

	var tween = create_tween()
	tween.set_parallel()

	#send our text up a bit
	tween.tween_property(self, "global_position", global_position + (Vector2.UP * 16), 0.3)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)


	tween.chain()

	#float our text up higher
	tween.tween_property(self, "global_position", global_position + (Vector2.UP * 48), 0.5)\
	.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)

	tween.tween_property(self, "scale", Vector2.ZERO, 0.5)\
	.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.chain()

	tween.tween_callback(queue_free)

	var scale_tween = create_tween()
	#make our text pop (scale)
	scale_tween.tween_property(self, "scale", Vector2.ONE * 1.75, 0.15)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	scale_tween.tween_property(self, "scale", Vector2.ONE, 0.15)\
	.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
