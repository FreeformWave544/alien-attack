extends Node2D

@onready var sessionLabel = $sessionScores

func _ready() -> void:
	var runs = Global.recentScores.size()
	var recentScores = Global.recentScores
	print("Session runs: ", runs)
	print("Recent scores: ", recentScores)
	sessionLabel.text = "Session Scores:"
	if Global.sessionRuns == 0:
		sessionLabel.text += "\nNo sessions completed yet."
		return
	var current_score = recentScores[-1]
	for i in range(1, Global.sessionRuns + 1):
		var diff_text = "N/A"
		var prev_score = 0
		if i > 1:
			prev_score = recentScores[i - 2]
			if prev_score != 0:
				var percent_diff = Global.percent_change(current_score, prev_score)
				diff_text = str(percent_diff)
		sessionLabel.text += "\nSession " + str(i) + ": " + str(current_score) + " (" + diff_text + ")"
		if i < recentScores.size():
			current_score = recentScores[i]

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/start_screen.tscn")
