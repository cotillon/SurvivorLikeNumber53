extends PanelContainer

signal selected

@onready var name_label: Label = $%NameLabel
@onready var description_label: Label = $%DescriptionLabel

var disabled = false


func _ready():
	gui_input.connect(on_gui_input)
	mouse_entered.connect(on_mouse_entered)



#play our into bounce animation, called from upgrade screen
func play_in(delay: float = 0):
	#make the card invisible until the animation starts
	modulate = Color.TRANSPARENT
	await get_tree().create_timer(delay).timeout	#allow for a delay between cards
	$AnimationPlayer.play("in")



func set_meta_upgrade(upgrade: MetaUpgrade):
	name_label.text = upgrade.name
	description_label.text = upgrade.description



func on_gui_input(event: InputEvent):
	if disabled:
		return

	if event.is_action_pressed("left_click"):
		select_card()


func select_card():
	disabled = true
	$AnimationPlayer.play("selected")


	await $AnimationPlayer.animation_finished
	selected.emit()


func on_mouse_entered():
	if disabled:
		return

	$HoverAnimationPlayer.play("hover")
