extends Control

func _on_email_submitted(new_text: String) -> void:
	var email: Dictionary = {
		"Email": $Panel/LineEdit.text.to_lower()
		}
	if email:
		await ApiManager.send_request("POST", "/users", email)
		if ApiManager.good == true:
			get_tree().change_scene_to_file("res://scenes/start_screen.tscn")
		else:
			get_tree().reload_current_scene()
