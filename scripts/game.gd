extends Node2D

@export var lives = 3
@export var fastRocketDuration: float = 2.0
var score: int = 0:
	set(v):
		score = v
		if fastRocketCharge < 100: fastRocketCharge += randf_range(0.01, 0.05)
		else: fastRocketCharge += randf_range(0.01, 0.5) / (fastRocketCharge / 100)
		_abilityChargeHandler()
		hud.set_score_label()
	get: return score
@onready var upgrader = preload("res://scenes/upgrades.tscn")
@onready var player = $Player
@onready var hud = $UI/HUD
@onready var end_scene = preload("res://scenes/game_over.tscn")
@onready var enemy_hit_sound = $EnemyHitSound
@onready var player_dmg = $PlayerDmg
@onready var boss = preload("res://scenes/boss.tscn")
@onready var plexusBackground = $ColorRect
var fastRocketCharge := 0.0
var ability_active: Dictionary = {}
var invincibility_active := false
var ghostly_phoenix_available := false
var slow_enemies_active := false
var eye_active := false

func _ready():
	Global.score = 0
	_setup_ability_timers()
	UpgradeManager.equippedUpgrades = []
	$mobile.visible = false
	hud.set_score_label()
	hud.set_upgrades()
	_abilityChargeHandler()
	hud.set_lives(lives)
	if Global.difficil == "easy": apply_easy_mode()
	elif Global.difficil == "hard": apply_hard_mode()
	if OS.has_feature("web_android") or OS.has_feature("web_ios"): $mobile.visible = true
	for i in range(4):
		for tim in range(10 * len(UpgradeManager.equippedUpgrades) + 10):
			$UI/HUD/Upgrades.value = (100.0 / (10.0 * len(UpgradeManager.equippedUpgrades) + 10)) * tim
			await get_tree().create_timer(1.0).timeout
			while is_inside_tree() and get_tree() and get_tree().paused:
				if is_inside_tree(): await get_tree().process_frame
				else: break
		var upgrade = upgrader.instantiate()
		add_child(upgrade)
		upgrade.toggle()
		await upgrade.upgradeClicked
		upgrade.queue_free()

var time_elapsed := 0.0
var oldScore = -1
func _process(delta: float) -> void:
	hud.set_upgrades()
	time_elapsed += delta
	Global.finalTime = float(time_elapsed)
	hud.time.text = "Time: %.2f" % time_elapsed
	if Global.score > oldScore:
		oldScore = Global.score
		if fastRocketCharge < 100: fastRocketCharge += randf_range(0.01, 0.05)
		else: fastRocketCharge += randf_range(0.01, 0.5) / (fastRocketCharge / 100)
		_abilityChargeHandler()
		hud.set_score_label()
		enemy_hit_sound.play()
	if Global.TakeLIVES:
		if ghostly_phoenix_available and Global.TakeLIVES > 0:
			_trigger_ghostly_phoenix()
			ghostly_phoenix_available = false
			Global.TakeLIVES = 0
		elif invincibility_active and Global.TakeLIVES > 0: Global.TakeLIVES = 0
		else:
			lives -= Global.TakeLIVES if not neurowave_active else Global.TakeLIVES * 2
			Global.TakeLIVES = 0

func _physics_process(delta):
	for i in range(4):
		var timer_key = "AB%dCD" % (i + 1)
		var timer_path = ABCDTimers.get(timer_key)
		if not timer_path: return
		var timer = get_node_or_null(timer_path)
		if not timer: return
		$UI/HUD/Upgrades.find_child("Ability" + str(i + 1)).value = 1.0 - (timer.time_left / ABCDs[i])
		if $UI/HUD/Upgrades.find_child("Ability" + str(i + 1)).value >= 1.0: $UI/HUD/Upgrades.find_child("Ability" + str(i + 1)).modulate.a = 1.0
		else: $UI/HUD/Upgrades.find_child("Ability" + str(i + 1)).modulate.a = 0.5
	hud.set_score_label()
	hud.set_lives(lives)
	if lives <= 0 and not ghostly_phoenix_available: dead()
	var direction = Vector2.ZERO
	if direction.length() > 0: direction = direction.normalized()
	player.position += direction * 200 * delta

func _unhandled_input(event: InputEvent) -> void:
	if !Global.fastRocketActive and fastRocketCharge > 1.0 and event.is_action("ultimate"): fastRocket()
	if Input.is_action_just_pressed("ability_1") and UpgradeManager.equippedUpgrades.size() > 0: use_ability(UpgradeManager.equippedUpgrades[0].ID, 0)
	if Input.is_action_just_pressed("ability_2") and UpgradeManager.equippedUpgrades.size() > 1: use_ability(UpgradeManager.equippedUpgrades[1].ID, 1)
	if Input.is_action_just_pressed("ability_3") and UpgradeManager.equippedUpgrades.size() > 2: use_ability(UpgradeManager.equippedUpgrades[2].ID, 2)
	if Input.is_action_just_pressed("ability_4") and UpgradeManager.equippedUpgrades.size() > 3: use_ability(UpgradeManager.equippedUpgrades[3].ID, 3)

func _on_deathzone_area_entered(area):
	if area.name == $Deathzone.name: return
	if area.find_child("Sprite2D").flip_v == true and area.is_in_group("enemy"): print("WITCH!") ; return
	if area.is_in_group("fireball"): area.blow()
	elif not area.is_in_group("dodge") and not area.is_in_group("fireball"):
		if invincibility_active: return
		score -= 50
		lives -= 1
		if lives <= 0:
			if ghostly_phoenix_available: _trigger_ghostly_phoenix()
			else:
				dead()
				player.die()
	elif not area.is_in_group("path") and not area.is_in_group("fireball"): area.queue_free()

func _on_player_took_damage():
	if lives <= 0:
		if ghostly_phoenix_available:
			_trigger_ghostly_phoenix()
		else:
			dead()

func dead():
	Global.run = false
	death()
	player.die()
	await get_tree().create_timer(1).timeout
	if !Global.run:
		var end_instance = end_scene.instantiate()
		if hud: hud.add_child(end_instance)

func _on_enemy_spawner_enemy_spawned(enemy_instance):
	enemy_instance.connect("died", _on_enemy_died)
	add_child(enemy_instance)
	if slow_enemies_active and enemy_instance.has_method("set_speed_multiplier"): enemy_instance.set_speed_multiplier(0.5)

func _on_enemy_died():
	score += 100
	hud.set_score_label()
	enemy_hit_sound.play()

func death():
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
	plexusBackground.modulate.a = 1.0
	Global.fastRocketActive = true
	await get_tree().create_timer(fastRocketDuration).timeout
	plexusBackground.modulate.a = 0.0
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

@export_category("Abilities")
@export var ABCDs: Array = [15.0, 20.0, 30.0, 45.0, 60.0]
@export var tiers: Array = [["Slow", "neurowave"], ["invincibility"], ["lifeExchange"], ["WalkingDead"], ["ghostPhoenix", "Eye"]]
@export var ABCDTimers: Dictionary = {
	"AB1CD": "ABCDs/Ability1", 
	"AB2CD": "ABCDs/Ability2",
	"AB3CD": "ABCDs/Ability3",
	"AB4CD": "ABCDs/Ability4"
}

func use_ability(ability: String, slot: int = 0) -> void:
	_setup_ability_timers()
	var timer_key = "AB%dCD" % (slot + 1)
	var timer_path = ABCDTimers.get(timer_key)
	if not timer_path: return
	var timer = get_node_or_null(timer_path)
	if not timer: return
	if timer.time_left > 0.0: return
	match ability:
		"invincibility": _activate_invincibility(timer)
		"lifeExchange": _activate_life_exchange(timer)
		"ghostPhoenix": _activate_ghostly_phoenix(timer)
		"Slow": _activate_slow_enemies(timer)
		"Eye": _activate_eye_of_chaos(timer)
		"WalkingDead": _activate_walking_dead(timer)
		"neurowave": _neurowave(timer)
		_: print("Unknown ability: ", ability)

func _activate_invincibility(timer: Timer) -> void:
	if invincibility_active:
		return
	invincibility_active = true
	$Player/Sprite2D.modulate = Color(4.0, 4.0, 4.0)
	var tween = create_tween()
	tween.set_loops(6)
	tween.tween_property($Player/Sprite2D, "modulate:a", 0.5, 0.25)
	tween.tween_property($Player/Sprite2D, "modulate:a", 1.0, 0.25)
	timer.start()
	await get_tree().create_timer(3.0).timeout
	invincibility_active = false
	$Player/Sprite2D.modulate = Color(1.0, 1.0, 1.0, 1.0)

var neurowave_active := false
func _neurowave(timer: Timer) -> void:
	if neurowave_active: return
	neurowave_active = true
	$Player.timer.wait_time /= 2.0
	var tween = create_tween()
	tween.set_loops(6)
	tween.tween_property($Neurowave, "color:a", 0.005, 0.25)
	tween.tween_property($Neurowave, "color:a", 0.025, 0.25)
	timer.start()
	await get_tree().create_timer(3.0).timeout
	$Player.timer.wait_time *= 2.0
	neurowave_active = false
	$Neurowave.color.a = 0.0
	await get_tree().process_frame
	$Neurowave.color.a = 0.0

var walking_dead_pool := []
var walking_dead_active := false
func _activate_walking_dead(timer: Timer) -> void:
	if walking_dead_active: return
	walking_dead_active = true
	$Player/Sprite2D.modulate = Color(1.7, 0.0, 0.0, 1.0)
	var tween = create_tween()
	tween.set_loops(6)
	tween.tween_property($Player/Sprite2D, "modulate:r", 1.5, 0.25)
	tween.tween_property($Player/Sprite2D, "modulate:r", 2.0, 0.2)
	timer.start()
	await get_tree().create_timer(10.0).timeout
	walking_dead_active = false
	$Player/Sprite2D.modulate = Color(1.0, 1.0, 1.0, 1.0)
	if len(walking_dead_pool) > 0:
		if len(walking_dead_pool) >= 10:
			Global.achievements["deadWalked"] = true
		for pos in walking_dead_pool:
			var enemyInst = preload("res://scenes/enemy.tscn").instantiate()
			add_child(enemyInst)
			enemyInst.modulate.g -= 0.2
			enemyInst.modulate.b -= 0.2
			enemyInst.global_position = pos
			enemyInst.speed = abs(enemyInst.speed) * -1
			enemyInst.find_child("Sprite2D").flip_v = !enemyInst.find_child("Sprite2D").flip_v
			enemyInst.set_collision_layer_value(3, true)
	for kiddo in $EnemySpawner.get_children():
		if "DeadMarker" in kiddo.name:
			kiddo.queue_free()
	walking_dead_pool.clear()

func _activate_life_exchange(timer: Timer) -> void:
	if Global.score < 200:
		return
	var score_to_convert = int(Global.score * 0.5)
	var lives_gained = max(1.0, score_to_convert / 1000.0)
	lives += lives_gained
	Global.score -= score_to_convert
	hud.set_lives(lives)
	hud.set_score_label()
	var tween = create_tween()
	tween.tween_property($Player, "scale", Vector2(1.3, 1.3), 0.2)
	tween.tween_property($Player, "scale", Vector2(1.0, 1.0), 0.2)
	timer.start()

func _activate_ghostly_phoenix(timer: Timer) -> void:
	ghostly_phoenix_available = true
	$Player/Sprite2D.modulate = Color(1.0, 1.0, 1.0, 0.7)
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property($Player/Sprite2D, "modulate", Color(1.5, 1.5, 0.5, 0.7), 1.0)
	tween.tween_property($Player/Sprite2D, "modulate", Color(1.0, 1.0, 1.0, 0.7), 1.0)
	timer.start()

func _trigger_ghostly_phoenix() -> void:
	if not ghostly_phoenix_available: return
	ghostly_phoenix_available = false
	lives = 2
	invincibility_active = true
	$Player/Sprite2D.modulate = Color(1.0, 1.0, 1.0, 1.0)
	var tween = create_tween()
	tween.tween_property($Player, "scale", Vector2(0.5, 0.5), 0.1)
	tween.tween_property($Player, "scale", Vector2(1.5, 1.5), 0.3)
	tween.tween_property($Player, "scale", Vector2(1.0, 1.0), 0.2)
	hud.set_lives(lives)
	await get_tree().create_timer(2.0).timeout
	invincibility_active = false

func _activate_slow_enemies(timer: Timer) -> void:
	if slow_enemies_active: return
	slow_enemies_active = true
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.has_method("set_speed_multiplier"): enemy.set_speed_multiplier(0.5)
	timer.start()
	await get_tree().create_timer(5.0).timeout
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.has_method("set_speed_multiplier"): enemy.set_speed_multiplier(false)
	slow_enemies_active = false

func _activate_eye_of_chaos(timer: Timer) -> void:
	if eye_active: return
	eye_active = true
	if not slow_enemies_active:
		slow_enemies_active = true
		for enemy in get_tree().get_nodes_in_group("enemies"):
			if enemy.has_method("set_speed_multiplier"): enemy.set_speed_multiplier(0.5)
	var shader_material = ShaderMaterial.new()
	if plexusBackground:
		plexusBackground.modulate.a = 1.0
	var original_time_scale = Engine.time_scale
	var shake_amount = 10.0
	var shake_duration = 1.0
	var shake_timer = 0.0
	var original_pos = player.position
	while shake_timer < shake_duration:
		player.position = original_pos + Vector2(randf_range(-shake_amount, shake_amount), randf_range(-shake_amount, shake_amount))
		shake_timer += get_process_delta_time()
		await get_tree().process_frame
	fastRocketCharge += 1.0
	fastRocket()
	player.position = original_pos
	timer.start()
	await get_tree().create_timer(8.0).timeout
	plexusBackground.modulate.a = 0.0
	eye_active = false
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.has_method("set_speed_multiplier"): enemy.set_speed_multiplier(false)
	slow_enemies_active = false

func _setup_ability_timers() -> void:
	for i in range(len(ABCDTimers.keys())):
		var timer_path = ABCDTimers[ABCDTimers.keys()[i]]
		var timer = get_node_or_null(timer_path)
		if timer and i < len(UpgradeManager.equippedUpgrades):
			for tier in tiers:
				for ability in tier:
					if ability == UpgradeManager.equippedUpgrades[i]["ID"]:
						timer.wait_time = ABCDs[tiers.find(tier)]
						timer.one_shot = true
						break
