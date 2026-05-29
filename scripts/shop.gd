extends Control

func _ready() -> void:
	for child in $Panel/GridContainer.get_children():
		if float(child.find_child("Price").text) > Global.score:
			child.find_child("Price").modulate = Color(1.0, 0.0, 0.0, 1.0)
		else:
			child.find_child("Price").modulate = Color(0.0, 1.0, 0.0, 1.0)
		child.find_child("Value").text = str(Global.upgrades[child.name]) if child.name in Global.upgrades else "Null"
