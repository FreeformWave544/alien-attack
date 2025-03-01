extends Node

var achievements: Dictionary = {} ; var isBoss: bool ; var canFire: bool = true ; var pathGot: bool ; var pathKills: int ; var score: int ; var TakeLIVES: int ; var addScore: int ; var player_name ; var finalTime: float ; var difficil = "norm"
var achieveSoundPlay ; var died: bool = true ; var bossLives = 2 ; var instructions = true
var high_scores = {
	"easy": 0,
	"norm": 0,
	"hard": 0
}

func _ready() -> void:
	load_achievements()

func save_scores():
	var json_string = JSON.stringify(high_scores)
	JavaScriptBridge.eval("localStorage.setItem('high_scores', '" + json_string + "');")

func save_achievements():
	var json_string = JSON.stringify(achievements)
	JavaScriptBridge.eval("localStorage.setItem('achievements', '" + json_string + "');")

func load_scores() -> Dictionary:
	var json_string = JavaScriptBridge.eval("localStorage.getItem('high_scores');")
	if json_string:
		high_scores = JSON.parse_string(json_string)
		if typeof(high_scores) == TYPE_DICTIONARY:
			print("High scores loaded:", high_scores)
		else:
			print("Error: Failed to parse high scores.")
	else:
		print("No high scores found.")
	return high_scores

func load_achievements() -> Dictionary:
	var json_string = JavaScriptBridge.eval("localStorage.getItem('achievements');")
	if json_string and json_string != "null":
		var data = JSON.parse_string(json_string)
		if typeof(data) == TYPE_DICTIONARY:
			achievements = data
	return achievements

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_PREDELETE:
		save_scores()
		save_achievements()
