extends Control

func _ready() -> void:
	get_tree().paused = true
	$Panel/Score.text = "Score: " + str(Global.score)
	for upgrd in UpgradeManager.equippedUpgrades:
		if $Panel/GridContainer.find_child(upgrd.ID): $Panel/GridContainer.find_child(upgrd.ID).show()
	for child in $Panel/GridContainer.get_children():
		if float(child.find_child("Price").text) > Global.score: child.find_child("Price").modulate = Color(1.0, 0.0, 0.0, 1.0)
		else: child.find_child("Price").modulate = Color(0.0, 1.0, 0.0, 1.0)
		if child.name in Global.upgrades: child.find_child("Value").text = str(Global.upgrades[child.name])
		else: Global.upgrades[child.name] = float(child.find_child("Value").text) ; _ready()
		if not child.find_child("Value").is_connected("pressed", upgrade): child.find_child("Value").pressed.connect(upgrade.bind(child.name))
	while visible:
		if !get_tree().paused: get_tree().paused = true
		await get_tree().create_timer(0.1).timeout

func upgrade(id = ""):
	if float($Panel/GridContainer.find_child("Price").text) <= Global.score:
		Global.upgrades[id] += 0.05
		Global.score -= float($Panel/GridContainer.find_child("Price").text)
		_ready()

func _on_back_pressed() -> void:
	get_tree().paused = false
	if get_parent() is not Window: queue_free()
	else: get_tree().change_scene_to_file("res://scenes/game.tscn")
