extends Node

var achievements: Dictionary = {} ;var isBoss: bool;var canFire: bool = true;var pathGot: bool ;var pathKills: int ;var score: int ;var TakeLIVES: int ;var addScore: int ;var player_name;var finalTime: float ;var difficil = "norm";var achieveSoundPlay;var died: bool = true ;var bossLives = 2 ;var instructions = true ;var WaitForMe: bool = false ;var url = "http://localhost:3000";var json_parser = JSON.new()
var high_scores = {"easy": 0, "norm": 0, "hard": 0}

func _ready() -> void:
	load_achievements()
	load_scores()
	high_scores["instructions"] = instructions

func set_scores(scores_dict: Dictionary):
	# Assuming the high_scores is a dictionary already initialized.
	high_scores["easy"] = scores_dict["easy"]
	high_scores["norm"] = scores_dict["norm"]
	high_scores["hard"] = scores_dict["hard"]

func save_scores():
	JavaScriptBridge.eval("localStorage.setItem('high_scores', '" + JSON.stringify(high_scores) + "');")

func save_achievements():
	JavaScriptBridge.eval("localStorage.setItem('achievements', '" + JSON.stringify(achievements) + "');")

func load_scores() -> Dictionary:
	var json_string = JavaScriptBridge.eval("localStorage.getItem('high_scores');")
	if json_string:
		high_scores = JSON.parse_string(json_string)
	return high_scores

func load_achievements() -> Dictionary:
	var json_string = JavaScriptBridge.eval("localStorage.getItem('achievements');")
	if json_string and json_string != "null" and json_string != "":
		achievements = JSON.parse_string(json_string)
	return achievements

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_PREDELETE:
		save_scores()
		save_achievements()

func get_current_animation_length(animated_sprite: AnimatedSprite2D) -> float:
	var current_animation_name = animated_sprite.animation
	if current_animation_name == "":
		return -1.0
	var sprite_frames = animated_sprite.sprite_frames
	if sprite_frames and sprite_frames.has_animation(current_animation_name):
		var num_frames = sprite_frames.get_frame_count(current_animation_name)
		var anim_speed = animated_sprite.speed_scale * sprite_frames.get_animation_speed(current_animation_name)
		if anim_speed > 0:
			return num_frames / anim_speed
	return -1.0
