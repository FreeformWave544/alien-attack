extends Control

func _on_login_pressed() -> void:
	get_tree().change_scene_to_file("res://addons/silent_wolf/Auth/Login.tscn")

func _on_register_pressed() -> void:
	get_tree().change_scene_to_file("res://addons/silent_wolf/Auth/Register.tscn")
