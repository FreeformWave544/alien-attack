extends Control

signal upgradeClicked

@export var upgrades: Array[UpgradeData]

const RARITY_COLORS := {
	"Common": Color(1, 1, 1), 
	"Uncommon": Color(0.2, 1, 0.2), 
	"Rare": Color(0.2, 0.6, 1), 
	"Epic": Color(0.7, 0.3, 0.9), 
	"Legendary": Color(1, 0.6, 0.1) }
const RARITY_WEIGHTS := {
	"Common": 70,
	"Uncommon": 50,
	"Rare": 20,
	"Epic": 8,
	"Legendary": 2
}

func _ready():
	get_cards()
	process_mode = Node.PROCESS_MODE_ALWAYS

func toggle():
	if get_tree() and is_inside_tree(): get_tree().paused = true

func _exit_tree() -> void: get_tree().paused = false

func pick_weighted_upgrade() -> UpgradeData:
	var pool: Array[UpgradeData] = []
	for upgrade in upgrades:
		if upgrade == null: continue
		if upgrade.rarity in RARITY_WEIGHTS:
			var weight = RARITY_WEIGHTS[upgrade.rarity]
			for i in range(weight): pool.append(upgrade)
	if pool.is_empty(): return null
	return pool.pick_random()

func get_cards(amount := 3):
	UpgradeManager.avaliableUpgrades.clear()
	var choices: Array[UpgradeData] = []
	for i in range(amount):
		var v: UpgradeData = pick_weighted_upgrade()
		while v in choices or v == null:
			v = pick_weighted_upgrade()
			await get_tree().process_frame
		choices.append(v)
	for x in choices:
		UpgradeManager.avaliableUpgrades[x.upgrade_name] = {
			"Type": x.type,
			"ID": x.ID,
			"Rarity": x.rarity,
			"Icon": x.icon,
			"Infused": true if x.infusible and (randi() % 100 + 1) > 70 else false}
	assign_available_cards()

func assign_available_cards() -> void:
	var container = $CanvasLayer/HBoxContainer
	var template = $CanvasLayer/Upgrade
	for child in container.get_children(): child.queue_free()
	for upgrade_name in UpgradeManager.avaliableUpgrades.keys():
		var upgrade_data = UpgradeManager.avaliableUpgrades[upgrade_name]
		var new_upgrade = template.duplicate()
		new_upgrade.name = upgrade_name
		new_upgrade.get_node("Sprite2D").texture = upgrade_data.Icon
		var rarity_label = new_upgrade.get_node("Rarity")
		rarity_label.text = upgrade_data.Rarity
		if upgrade_data.Rarity in RARITY_COLORS: rarity_label.add_theme_color_override("font_color", RARITY_COLORS[upgrade_data.Rarity])
		new_upgrade.get_node("Type").text = upgrade_data.Type if not upgrade_data.Infused else "Infused"
		new_upgrade.get_node("Name").text = upgrade_name
		if new_upgrade.has_node("Background"):
			new_upgrade.get_node("Background").modulate = RARITY_COLORS.get(upgrade_data.Rarity, Color.WHITE)
		var button = new_upgrade.get_node("Button")
		button.pressed.connect(Callable(self, "_on_upgrade_pressed").bind(upgrade_data))
		container.add_child(new_upgrade)
	template.visible = false

func _on_upgrade_pressed(data) -> void:
	emit_signal("upgradeClicked")
	UpgradeManager.equippedUpgrades.append(data)
	if get_parent().has_method("mobileUpdate"): get_parent().mobileUpdate()
	get_child(0).hide()
	get_tree().paused = false
