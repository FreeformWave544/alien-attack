extends Node2D

@export var lives = 3
@export var fastRocketDuration: float = 2.0
var score: int = 0:
	set(v):
		score = v
		if fastRocketCharge < 100:
			fastRocketCharge += randf_range(0.01, 0.05)
		else:
			fastRocketCharge += randf_range(0.01, 0.5) / (fastRocketCharge / 100)
		_abilityChargeHandler()
		hud.set_score_label()
	get:
		return score
@onready var upgrader = preload("res://scenes/upgrades.tscn")
@onready var player = $Player
@onready var hud = $UI/HUD
@onready var end_scene = preload("res://scenes/game_over.tscn")
@onready var enemy_hit_sound = $EnemyHitSound
@onready var player_dmg = $PlayerDmg
@onready var boss = preload("res://scenes/boss.tscn")
@onready var plexusParticles = preload("res://PlexusParticles.gdshader")
@onready var plexusBackground = find_child("ColorRect")
var fastRocketCharge := 0.0

func _ready():
	Global.score = 0
	UpgradeManager.equippedUpgrades = []
	$mobile.visible = false
	hud.set_score_label()
	hud.set_lives(lives)
	if Global.difficil == "easy":
		apply_easy_mode()
	elif Global.difficil == "hard":
		apply_hard_mode()
	if OS.has_feature("web_android") or OS.has_feature("web_ios"):
		$mobile.visible = true
	await get_tree().create_timer(10).timeout
	var upgrade = upgrader.instantiate()
	add_child(upgrade)
	upgrade.toggle()

var time_elapsed := 0.0
func _process(delta: float) -> void:
	hud.set_upgrades()
	time_elapsed += delta
	Global.finalTime = float(time_elapsed)
	hud.time.text = "Time: %.2f" % time_elapsed
	if Global.addScore != 0:
		score += Global.addScore
		Global.addScore = 0
		enemy_hit_sound.play()
	if Global.TakeLIVES:
		lives -= Global.TakeLIVES
		Global.TakeLIVES = 0

func _physics_process(delta):
	hud.set_score_label()
	hud.set_lives(lives)
	if lives <= 0:
		dead()
	var direction = Vector2.ZERO
	if direction.length() > 0:
		direction = direction.normalized()
	player.position += direction * 200 * delta

func _unhandled_input(event: InputEvent) -> void:
	if !Global.fastRocketActive and fastRocketCharge > 1.0 and event.is_action("ability1"): fastRocket()

func _on_deathzone_area_entered(area):
	if area.is_in_group("fireball"):
		area.blow()
	elif not area.is_in_group("dodge") and not area.is_in_group("fireball"):
		score -= 50
		lives -= 1
		if lives <= 0:
			dead()
			player.die()
	elif not area.is_in_group("path") and not area.is_in_group("fireball"):
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
		if hud: hud.add_child(end_instance)
		else: print("HUD is null!")

func _on_enemy_spawner_enemy_spawned(enemy_instance):
	enemy_instance.connect("died", _on_enemy_died)
	add_child(enemy_instance)

func _on_enemy_died():
	print(score)
	score += 100
	hud.set_score_label()
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

func fastRocket():
	fastRocketCharge -= 1.0
	Engine.time_scale = 0.5
	var shader_material = ShaderMaterial.new()
	shader_material.shader = plexusParticles
	plexusBackground.material = shader_material
	Global.fastRocketActive = true
	await get_tree().create_timer(fastRocketDuration).timeout
	plexusBackground.material = ShaderMaterial.new()
	Global.fastRocketActive = false
	Engine.time_scale = 1.0

func _on_up_button_down(): player.move_up()
func _on_up_button_up(): player.move_up(false)
func _on_down_button_down(): player.move_down()
func _on_down_button_up(): player.move_down(false)
func _on_left_button_down(): player.move_left()
func _on_left_button_up(): player.move_left(false)
func _on_right_button_down(): player.move_right()
func _on_right_button_up(): player.move_right(false)
func _on_shoot_button_down(): player.shoot()

func _abilityChargeHandler():
	$UI/HUD/AbilityChargeProgress.value = fastRocketCharge
