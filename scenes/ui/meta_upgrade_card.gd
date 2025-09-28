extends PanelContainer

@onready var name_label: Label = $%NameLabel
@onready var description_label: Label = $%DescriptionLabel
@onready var progress_bar: ProgressBar = $%ProgressBar
@onready var purchase_button: Button = %PurchaseButton
@onready var progress_label: Label = %ProgressLabel

var upgrade_ref: MetaUpgrade


func _ready():
	purchase_button.pressed.connect(on_purchase_pressed)


func set_meta_upgrade(upgrade: MetaUpgrade):
	upgrade_ref = upgrade
	name_label.text = upgrade.title
	description_label.text = upgrade.description
	update_progress()

# TODO: format the progress label text
func update_progress():
	var currency = MetaProgression.save_data["meta_upgrade_currency"]
	var percent = currency / upgrade_ref.experience_cost
	percent = min(percent, 1)
	progress_bar.value = percent
	purchase_button.disabled = percent < 1
	progress_label.text = str(currency) + "/" + str(upgrade_ref.experience_cost)


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
