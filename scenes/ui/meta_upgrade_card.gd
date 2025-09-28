extends PanelContainer

@onready var name_label: Label = $%NameLabel
@onready var description_label: Label = $%DescriptionLabel
@onready var progress_bar: ProgressBar = $%ProgressBar
@onready var purchase_button: Button = %PurchaseButton
@onready var progress_label: Label = %ProgressLabel
@onready var count_label: Label = %CountLabel

var upgrade_ref: MetaUpgrade


func _ready():
	purchase_button.pressed.connect(on_purchase_pressed)


func set_meta_upgrade(upgrade: MetaUpgrade):
	upgrade_ref = upgrade
	name_label.text = upgrade.title
	description_label.text = upgrade.description
	update_progress()


func update_progress():
	var current_quantity = 0
	if MetaProgression.save_data["meta_upgrades"].has(upgrade_ref.id):
		current_quantity = MetaProgression.save_data["meta_upgrades"][upgrade_ref.id]["quantity"]

	var is_maxed = current_quantity >= upgrade_ref.max_quantity
	var currency = MetaProgression.save_data["meta_upgrade_currency"]
	var percent = currency / upgrade_ref.experience_cost
	percent = min(percent, 1)
	progress_bar.value = percent
	purchase_button.disabled = percent < 1 or is_maxed
	if is_maxed:
		purchase_button.text = "Max"
	progress_label.text = str(currency) + "/" + str(upgrade_ref.experience_cost)
	count_label.text = "x%d" % current_quantity


func select_card():
	$AnimationPlayer.play("selected")


func on_purchase_pressed():
	if upgrade_ref == null:
		return
	MetaProgression.add_meta_upgrade(upgrade_ref)
	MetaProgression.save_data["meta_upgrade_currency"] -= upgrade_ref.experience_cost
	MetaProgression.save()
	get_tree().call_group("meta_upgrade_card", "update_progress")
	$AnimationPlayer.play("selected")
