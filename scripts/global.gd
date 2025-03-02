extends Node

var achievements: Dictionary = {} ; var isBoss: bool ; var canFire: bool = true ; var pathGot: bool ; var pathKills: int ; var score: int ; var TakeLIVES: int ; var addScore: int ; var player_name ; var finalTime: float ; var difficil = "norm"
var achieveSoundPlay ; var died: bool = true ; var bossLives = 2 ; var instructions = true
var high_scores = {
	"easy": 0,
	"norm": 0,
	"hard": 0,
	"instructions": instructions,
	"playername": player_name
}

func _ready() -> void:
	load_achievements()
	load_scores()
	high_scores["instructions"] = instructions

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

func get_current_animation_length(animated_sprite: AnimatedSprite2D) -> float:
	var current_animation_name = animated_sprite.animation
	if current_animation_name == "":
		print("No animation is currently playing.")
		return -1.0
		var sprite_frames = animated_sprite.sprite_frames
		if sprite_frames and sprite_frames.has_animation(current_animation_name):
			var num_frames = sprite_frames.get_frame_count(current_animation_name)
			var anim_speed = animated_sprite.speed_scale * sprite_frames.get_animation_speed(current_animation_name)
			if anim_speed > 0:
				return num_frames / anim_speed
		else:
			print("Animation speed is zero or negative.")
			return -1.0
	else:
		print("Animation not found: ", current_animation_name)
		return -1.0
