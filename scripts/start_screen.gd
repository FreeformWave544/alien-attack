extends Control

@onready var HighScores = $Panel/HighScores
@export var scrollSpeed := 40.0

func _ready() -> void:
	var waffles = true
	var scores = Global.load_scores()
	while not Global.WaitForMe:
		await get_tree().create_timer(0.1).timeout
		HighScores.text = "High Scores:\n   Easy: %.1f\n   Normal: %.1f\n   Hard: %.1f" % [scores["easy"], scores["norm"], scores["hard"]]
		if waffles and Global.instructions:
			waffles = false
			var instructions = load("res://scenes/instructions.tscn")
			var instructionsInstance = instructions.instantiate()
			$Panel.add_child(instructionsInstance)

func _on_button_2_pressed() -> void:
	Global.difficil = "norm"
	Global.transition("res://scenes/game.tscn", $ParallaxBackground.scroll_offset)

func _on_button_pressed() -> void:
	Global.difficil = "easy"
	Global.transition("res://scenes/game.tscn", $ParallaxBackground.scroll_offset)

func _hard_pressed() -> void:
	Global.difficil = "hard"
	Global.transition("res://scenes/game.tscn", $ParallaxBackground.scroll_offset)

func _on_achievements_pressed() -> void:
	Global.transition("res://scenes/achievements.tscn", $ParallaxBackground.scroll_offset)

func _on_session_scores_pressed() -> void:
	Global.transition("res://scenes/session_scores.tscn", $ParallaxBackground.scroll_offset)

func _on_volume_pressed() -> void:
	Global.transition("res://scenes/volumeMeter.tscn", $ParallaxBackground.scroll_offset)

func _on_options_pressed() -> void:
	add_child(load("res://addons/maaacks_options_menus/base/scenes/menus/options_menu/master_options_menu_with_tabs.tscn").instantiate())

func _on_upgrades_pressed() -> void:
	Global.transition("res://scenes/upgrades.tscn", $ParallaxBackground.scroll_offset)
