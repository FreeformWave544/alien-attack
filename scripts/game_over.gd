extends Control

var recentScores = {}
@onready var highScore: int = 0
@onready var bronze = preload("res://scenes/medals/bronze_medal.tscn")
@onready var silver = preload("res://scenes/medals/silver_medal.tscn")
@onready var gold = preload("res://scenes/medals/gold_medal.tscn")
@onready var platinum = preload("res://scenes/medals/platinum_medal.tscn")
@onready var diffMulti: Label = $Panel/DiffMulti
var medalPos = Vector2(400, 252)
var run: bool = false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	if int(Global.finalTime) >= 0 and !Global.run:
		match Global.difficil:
			"norm":
				diffMulti.text = "Difficulty Multiplier: \n1.5x"
				@warning_ignore("narrowing_conversion")
				Global.score *= 1.5
			"hard":
				diffMulti.text = "Difficulty Multiplier: \n2.0x"
				@warning_ignore("narrowing_conversion")
				Global.score *= 2.0
			_:
				diffMulti.text = "No Difficulty Multiplier"
		Global.run = true
		fetch_best_score()
		get_tree().paused = true
	Global.pathKills = 0

func fetch_best_score():
	Global.save_scores()
	if Global.pathKills > 10:
		Global.achievements["path10"] = true
	if Global.score > Global.high_scores[Global.difficil]:
		Global.high_scores[Global.difficil] = Global.score
		await ApiManager.send_request("POST", "/scores", Global.high_scores)
	print(Global.score, " -=-=-")
	$Panel/Score.text = "SCORE: " + str(Global.score) + "\nBEST SCORE: " + str(Global.high_scores[Global.difficil])
	$Panel/FinalTime.text = "Final Time: %.2f" % Global.finalTime
	display_medal(Global.score)

func display_medal(score: int):
	Global.sessionRuns += 1
	Global.recentScores.append(score)
	if Global.score >= 10000:
		var platinum_instance = platinum.instantiate()
		platinum_instance.global_position = medalPos
		add_child(platinum_instance)
	elif Global.score >= 3000:
		var gold_instance = gold.instantiate()
		gold_instance.global_position = medalPos
		add_child(gold_instance)
	elif Global.score >= 750:
		var silver_instance = silver.instantiate()
		silver_instance.global_position = medalPos
		add_child(silver_instance)
	else:
		var bronze_instance = bronze.instantiate()
		bronze_instance.global_position = medalPos
		add_child(bronze_instance)
		
	if Global.score >= 12800 and Global.difficil == "easy":
		Global.achievements["HHigh"] = true

func _on_retry_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/start_screen.tscn")
