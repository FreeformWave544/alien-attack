extends Node2D

@onready var sessionLabel = $sessionScores

func _ready() -> void:
	sessionLabel.text = "Session Scores:"
	for i in range(1, Global.sessionRuns + 1):
		var diff_text = "N/A"
		if i > 1:
			var prev_score = Global.recentScores.get(i - 1, 0)
			var current_score = Global.recentScores.get(i, 0)
			if prev_score != 0:
				var percent_diff = Global.percent_change(current_score, prev_score)
				diff_text = str(percent_diff)
		sessionLabel.text += "\nScore " + str(i) + ": " + str(Global.recentScores.get(i, 0)) + " (" + diff_text + ")"


func _on_back_pressed() -> void:
	print(Global.sessionRuns , Global.recentScores)
	get_tree().change_scene_to_file("res://scenes/start_screen.tscn")
