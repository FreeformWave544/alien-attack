extends Control

@onready var HighScores = $Panel/HighScores
@export var scrollSpeed := 40.0

func _ready() -> void:
	var waffles = true
	var scores = await Global.load_scores()
	while not Global.WaitForMe:
		await get_tree().create_timer(0.1).timeout
		HighScores.text = "High Scores:\n" + "   Easy: " + str(scores["easy"]) + "\n   Normal: " + str(scores["norm"]) + "\n   Hard: " + str(scores["hard"])
		for key in scores:
			if int(key) == 0:
				if waffles and Global.instructions:
					waffles = false
					var instructions = load("res://scenes/instructions.tscn")
					var instructionsInstance = instructions.instantiate()
					$Panel.add_child(instructionsInstance)
					instructionsInstance.visible = false

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

func _on_session_scores_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/session_scores.tscn")

func _on_volume_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/volumeMeter.tscn")

func _on_options_pressed() -> void:
	add_child(load("res://addons/maaacks_options_menus/base/scenes/menus/options_menu/master_options_menu_with_tabs.tscn").instantiate())


func _on_upgrades_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/upgrades.tscn")
