extends Node

var achievements: Dictionary = {} ;var isBoss: bool;var canFire: bool = true;var pathGot: bool ;var pathKills: int ;var score: int ;var TakeLIVES: int ;
var addScore: int:
	set(v): 
		score += v
var player_name;var finalTime: float ;var difficil = "norm";
var died: bool = true ;var bossLives = 200 ;var instructions = true ;var WaitForMe: bool = false ;var url = "http://localhost:3000";var json_parser = JSON.new()
var high_scores = {"easy": 0, "norm": 0, "hard": 0}
var jwt_token: String = "" ; var sessionRuns: int = 0 ; var recentScores = [] ; var volume: int = 20
var run := false ; var fastRocketActive := false
var scroll_offset := Vector2.ZERO
var playWhilePaused := false

func _ready() -> void:
	load_achievements() ; load_scores()
	high_scores["instructions"] = instructions
	await get_tree().create_timer(0.5).timeout
	save_stuff("norm")

func save_stuff(diffic):
	var config = ConfigFile.new()
	config.set_value("player", "highscore", high_scores[diffic])
	config.set_value("settings", "volume", volume)
	config.save("user://settings.cfg")

func load_stuff(diffic):
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err == OK:
		var highscore = config.get_value("player", "highscore", 0)
		var vol = config.get_value("settings", "volume", 1.0)
		high_scores[diffic] = highscore
		volume = vol
		return str(highscore) + " " + str(vol)
	else:
		return "Failed to load config."

func percent_change(new_value, old_value):
	if old_value == 0:
		return "0.0%"
	var change = (new_value - old_value) / old_value * 100
	if change > 0:
		return "+" + str(change) + "%"
	elif change < 0:
		return str(change) + "%"
	else:
		return "0%"

func set_scores(scores_dict: Dictionary):
	high_scores["easy"] = scores_dict["easy"]
	high_scores["norm"] = scores_dict["norm"]
	high_scores["hard"] = scores_dict["hard"]

func save_scores():
	JavaScriptBridge.eval("localStorage.setItem('high_scores', '" + JSON.stringify(high_scores) + "');")

func save_achievements():
	JavaScriptBridge.eval("localStorage.setItem('achievements', '" + JSON.stringify(achievements) + "');")

func save_JWT():
	JavaScriptBridge.eval("localStorage.setItem('JWT', '" + JSON.stringify(jwt_token) + "');")

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

func transition(target: String, scrollOffsets: Vector2 = Vector2.ZERO) -> void:
	while Transition.find_child("Fade").color.a < 0.9: Transition.find_child("Fade").color.a += 0.05 ; await get_tree().process_frame
	Transition.find_child("Fade").color.a = 1.0
	get_tree().change_scene_to_file(target)
	scroll_offset = scrollOffsets
	await get_tree().process_frame
	while Transition.find_child("Fade").color.a > 0.1: Transition.find_child("Fade").color.a -= 0.05 ; await get_tree().create_timer(0.1).timeout
	Transition.find_child("Fade").color.a = 0.0
