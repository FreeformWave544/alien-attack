extends Control

#func _ready() -> void:
	#$Panel/LineEdit.MAKE_ME_BE_FOCUSED

func try_again():
	$Panel/LineEdit.text = "" ; $Panel/LineEdit.placeholder_text = "Try again"

func _on_email_submitted(new_text: String) -> void:
	var email: Dictionary = {
		"Email": $Panel/LineEdit.text.to_lower()
		}
	if $Panel/LineEdit.text:
		await ApiManager.send_request("POST", "/users", email)
		if Global.jwt_token: Global.transition("res://scenes/start_screen.tscn")
		else: try_again()
	else:get_tree().reload_current_scene()
