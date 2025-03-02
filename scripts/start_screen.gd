extends Control

@onready var HighScores = $Panel/HighScores
func _ready() -> void:
	var scores = await Global.load_scores()
	var waffles = true
	HighScores.text = "High Scores:\n" + "   Easy: " + str(scores["easy"]) + "\n   Normal: " + str(scores["norm"]) + "\n   Hard: " + str(scores["hard"])
	for key in scores:
		if int(key) == 0:
			if waffles and Global.instructions:
				waffles = false
				var instructions = load("res://scenes/instructions.tscn")
				var instructionsInstance = instructions.instantiate()
				$Panel.add_child(instructionsInstance)

func _on_button_2_pressed() -> void:
	Global.difficil = "norm"
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_button_pressed() -> void:
	Global.difficil = "easy"
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _hard_pressed() -> void:
	Global.difficil = "hard"
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_achievements_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/achievements.tscn")
