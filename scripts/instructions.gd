extends Control

func _on_close_pressed() -> void:
	if $Panel/VBoxContainer/CheckButton.toggled: Global.instructions = false
	else: Global.instructions = true
	visible = false

func _on_check_button_toggled(toggled_on: bool) -> void:
	Global.instructions = !toggled_on
