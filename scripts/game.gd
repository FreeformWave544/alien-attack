extends Node2D

@onready var lives = 3
@onready var score: int = 0
@onready var player = $Player
@onready var hud = $UI/HUD
@onready var end_scene = preload("res://scenes/game_over.tscn")
@onready var enemy_hit_sound = $EnemyHitSound
@onready var player_dmg = $PlayerDmg
@onready var boss = preload("res://scenes/boss.tscn")

var move_up = false
var move_down = false
var move_left = false
var move_right = false
var is_shooting = false

func _ready():
	$mobile.visible = false
	hud.set_score_label(score)
	hud.set_lives(lives)
	if Global.difficil == "easy":
		apply_easy_mode()
	elif Global.difficil == "hard":
		apply_hard_mode()
	if OS.has_feature("web_android") or OS.has_feature("web_ios"):
		$mobile.visible = true
	await get_tree().create_timer(200).timeout
	var bossInstance = boss.instantiate()
	add_child(bossInstance)
	Global.isBoss = true
	bossInstance.global_position = Vector2(1400, 360)

var time_elapsed := 0.0

func _process(delta: float) -> void:
	time_elapsed += delta
	Global.finalTime = float(time_elapsed)
	if Global.addScore != 0:
		score += Global.addScore
		Global.addScore = 0
		enemy_hit_sound.play()
	if Global.TakeLIVES:
		lives -= Global.TakeLIVES
		Global.TakeLIVES = 0

func _physics_process(delta):
	hud.set_score_label(score)
	hud.set_lives(lives)
	if lives <= 0:
		dead()
	var direction = Vector2.ZERO
	if move_up:
		direction.y -= 1
	if move_down:
		direction.y += 1
	if move_left:
		direction.x -= 1
	if move_right:
		direction.x += 1

	if direction.length() > 0:
		direction = direction.normalized()
	player.position += direction * 200 * delta

func _on_deathzone_area_entered(area):
	if area.is_in_group("fireball"):
		area.blow()
	if not area.is_in_group("dodge") and not area.is_in_group("fireball"):
		score -= 50
		lives -= 1
		if lives <= 0:
			dead()
			player.die()
	if not area.is_in_group("path") and not area.is_in_group("fireball"):
		area.queue_free()

func _on_player_took_damage():
	player_dmg.play()
	lives -= 1
	score -= 100
	hud.set_lives(lives)
	if lives <= 0:
		dead()

func dead():
	Global.run = false
	death()
	player.die()
	await get_tree().create_timer(1).timeout
	if !Global.run:
		var end_instance = end_scene.instantiate()
		match Global.difficil:
			"norm":
				score *= 1.
			"hard":
				score *= 2.0
			_:
				print("No multiplier applied. Score: ", score)
		end_instance.score = score
		Global.score = score
		if hud:
			hud.add_child(end_instance)
		else:
			print("HUD is null!")

func _on_enemy_spawner_enemy_spawned(enemy_instance):
	enemy_instance.connect("died", _on_enemy_died)
	add_child(enemy_instance)

func _on_enemy_died():
	score += 100
	hud.set_score_label(score)
	enemy_hit_sound.play()

func death():
	for i in 3:
		player_dmg.play()

func apply_easy_mode():
	lives = 5
	hud.set_lives(lives)
	$Player/easyview.visible = true

func apply_hard_mode():
	lives = 1
	hud.set_lives(lives)

func _on_up_button_down(): move_up = true
func _on_up_button_up(): move_up = false
func _on_down_button_down(): move_down = true
func _on_down_button_up(): move_down = false
func _on_left_button_down(): move_left = true
func _on_left_button_up(): move_left = false
func _on_right_button_down(): move_right = true
func _on_right_button_up(): move_right = false

func _on_shoot_button_down():
	is_shooting = true

func _on_shoot_button_up():
	is_shooting = false
