extends Control

signal upgradeClicked

@export var upgrades: Array[UpgradeData]

func _ready():
	get_cards()
	process_mode = Node.PROCESS_MODE_ALWAYS

func toggle():
	get_tree().paused = !get_tree().paused

func get_cards(amount := 3):
	var choices := []
	for i in range(amount):
		var v = upgrades.pick_random()
		while v in choices or v == null:
			v = upgrades.pick_random()
			await get_tree().process_frame
		choices.append(v)
	for x in choices:
		UpgradeManager.avaliableUpgrades[x.upgrade_name] = {}
		UpgradeManager.avaliableUpgrades[x.upgrade_name]["Type"] = x.type
		UpgradeManager.avaliableUpgrades[x.upgrade_name]["ID"] = x.ID
		UpgradeManager.avaliableUpgrades[x.upgrade_name]["Rarity"] = x.rarity
		UpgradeManager.avaliableUpgrades[x.upgrade_name]["Icon"] = x.icon
	assign_available_cards()

func assign_available_cards() -> void:
	var container = $CanvasLayer/HBoxContainer
	var template = container.get_node("Upgrade")
	for child in container.get_children(): if child != template: child.queue_free()
	for upgrade_name in UpgradeManager.avaliableUpgrades.keys():
		var upgrade_data = UpgradeManager.avaliableUpgrades[upgrade_name]
		var new_upgrade = template.duplicate()
		new_upgrade.name = upgrade_name
		new_upgrade.get_node("Sprite2D").texture = upgrade_data.Icon
		new_upgrade.get_node("Rarity").text = upgrade_data.Rarity
		new_upgrade.get_node("Type").text = upgrade_data.Type
		new_upgrade.get_node("Name").text = upgrade_name
		var button = new_upgrade.get_node("Button")
		button.pressed.connect(Callable(self, "_on_upgrade_pressed").bind(upgrade_data))
		container.add_child(new_upgrade)
	template.visible = false

func _on_upgrade_pressed(data) -> void:
	UpgradeManager.equippedUpgrades.append(data)
	get_child(0).hide()
	get_tree().paused = false
