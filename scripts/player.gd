extends CharacterBody2D
class_name Player
signal took_damage

var rocket_scene = preload("res://scenes/rocket.tscn")

@export var AbSpeedMulti := 1.0
@export var speed = 300.0
@onready var laser = $Laser
@onready var rocket_container = $"../../Player/RocketContainer" if get_parent().name == "Doubles" else $RocketContainer
@onready var timer = $TextureProgressBar/Timer
@onready var easyview = $easyview
var fade_speed = 1.5
var fading_in = 0

func _ready():
	easyview.modulate.a = 0.0
	$plo.visible = false
	$plo.process_mode = Node.PROCESS_MODE_ALWAYS
	$Laser.volume_db = Global.volume - 30
	match Global.difficil:
		"easy": responsiveness = 18.0
		"norm": responsiveness = 10.0
		"hard": responsiveness = 4.0

func _process(delta):
	if Input.is_action_just_pressed("shoot"): shoot()
	if Global.difficil == "easy":
		if fading_in == 0: start_fade_in()
	if fading_in == 1:
		easyview.modulate.a = min(easyview.modulate.a + (delta * fade_speed), 1.0)
		if easyview.modulate.a >= 1.0: start_fade_out()
	elif fading_in == -1:
		easyview.modulate.a = max(easyview.modulate.a - (delta * (fade_speed+(fade_speed * 0.5))), 0.0)
		if easyview.modulate.a <= 0.0: start_fade_in()

func start_fade_in(): fading_in = 1

func start_fade_out(): fading_in = -1

@export var responsiveness := 0.5
var projSpeed = 500.0
func _physics_process(delta):
	projSpeed = 500.0 * delta
	velocity = lerp(velocity, speed * Input.get_vector("move_left", "move_right", "move_up", "move_down"), 1.0 - exp(-responsiveness * delta))
	if Input.is_action_pressed("debug") and OS.is_debug_build(): $Debug.visible = !$Debug.visible ; get_tree().paused = $Debug.visible
	move_and_slide()
	var screen_size = get_viewport_rect().size
	global_position = global_position.clamp(Vector2(0,0), screen_size)

var laser_active = false
func _laser():
	var pew = $Pew.duplicate()
	add_child(pew)
	pew.show()
	pew.global_position = global_position
	pew.get_child(0).color = Color(4.416, 0.0, 4.416, 0.498)
	if laser_active is not bool:
		laser.pitch_scale = randf_range(1.2, 1.6)
		laser.play()
		while pew.global_position.x < 1300.0:
			await get_tree().process_frame
			if get_tree().paused: continue
			pew.global_position.x += 10.0 * float(Global.upgrades["laser"]) if "laser" in Global.upgrades else 10.0
	else:
		pew.get_child(0).color = Color(4.416, 4.416, 2.987, 0.667)
		for i in range(8): pew.scale.x += 32.0/8.0 ; await get_tree().process_frame
		await get_tree().create_timer(0.5).timeout
		while pew.modulate.a >= 0.05:
			pew.modulate.a -= 0.01
			await get_tree().process_frame
	pew.queue_free()

func shoot():
	if laser_active: _laser() ; return
	if not ((timer.time_left == 0 or Global.fastRocketActive) and Global.canFire): return
	var rocket_instance = rocket_scene.instantiate()
	rocket_container.add_child(rocket_instance)
	rocket_instance.global_position = global_position
	rocket_instance.global_position.x += 80
	timer.one_shot = true
	timer.start()
	laser.pitch_scale = randf_range(0.8, 1.2)
	laser.play()

func take_damage(v := 1):
	Global.TakeLIVES += v
	emit_signal("took_damage")

func die():
	if Global.died:
		return
	Global.died = true
	$Sprite2D.visible = false
	$Flame.visible = false
	$TextureProgressBar.visible = false
	$plo.visible = true
	$plo.scale = Vector2(4,4)
	$plo.play("default")
	await $plo.animation_finished

var uv := false
func move_up():
	uv = !uv
	while uv == true: 
		Input.action_press("move_up")
		await get_tree().process_frame
	Input.action_release("move_up")

var dv := false
func move_down():
	dv = !dv
	while dv == true: 
		Input.action_press("move_down")
		await get_tree().process_frame
	Input.action_release("move_down")

var lv := false
func move_left():
	lv = !lv
	while lv == true: 
		Input.action_press("move_left")
		await get_tree().process_frame
	Input.action_release("move_left")

var rv := false
func move_right():
	rv = !rv
	while rv == true: 
		Input.action_press("move_right")
		await get_tree().process_frame
	Input.action_release("move_right")

func _surge() -> bool:
	var surgeInst = preload("res://scenes/surge.tscn").instantiate()
	add_child(surgeInst, true)
	if not surgeInst: return false
	surgeInst.global_position = global_position
	surgeInst.connect("area_entered", _on_surge_area_entered)
	surgeInst.show()
	while surgeInst.global_position.x < 1280.0:
		if get_tree() and get_tree().paused: await get_tree().process_frame ; continue
		surgeInst.global_position.x += projSpeed
		if is_inside_tree() and get_tree(): await get_tree().process_frame
	for i in range(10):
		surgeInst.modulate.a -= 0.1
		surgeInst.global_position.x += 1.0
		if is_inside_tree() and get_tree(): await get_tree().process_frame
	surgeInst.hide()
	surgeInst.queue_free()
	return true

func _homing_head(speedMulti := 1.0):
	var homingInst = preload("res://scenes/homing.tscn").instantiate()
	add_child(homingInst, true)
	homingInst.global_position = global_position
	homingInst.connect("area_entered", _on_homing_area_entered)
	var startTime := Time.get_unix_time_from_system()
	var targetEnemy = $"../EnemySpawner/SpawnPositions".get_children().pick_random()
	if targetEnemy is Path2D or targetEnemy is PathFollow2D: targetEnemy = targetEnemy.get_child(0).get_child(0)
	while Time.get_unix_time_from_system() - startTime <= 5.0:
		if get_tree() and is_inside_tree() and (get_tree().paused or not homingInst): await get_tree().process_frame ; continue
		if not homingInst and homingInst.global_position.x >= 1280.0: homingInst.global_position.x -= 0.1 ; await get_tree().process_frame
		if not targetEnemy and not (len($"../EnemySpawner/SpawnPositions".get_children()) <= 0): targetEnemy = $"../EnemySpawner/SpawnPositions".get_children().pick_random()
		homingInst.global_position.x = move_toward(homingInst.global_position.x, targetEnemy.global_position.x, projSpeed * speedMulti) if targetEnemy else homingInst.global_position.x + 0.1
		homingInst.global_position.y = move_toward(homingInst.global_position.y, targetEnemy.global_position.y, projSpeed * speedMulti) if targetEnemy else homingInst.global_position.y
		if is_inside_tree() and get_tree(): await get_tree().process_frame
	for i in range(20):
		if not homingInst: return true
		homingInst.modulate.a -= 0.05
		homingInst.global_position = Vector2(move_toward(homingInst.global_position.x, global_position.x, projSpeed), move_toward(homingInst.global_position.y, global_position.y, projSpeed))
		await get_tree().process_frame
	homingInst.queue_free()
	return true

func _on_surge_area_entered(area: Area2D) -> void:
	if area.is_in_group("fireball"): return
	if area.is_in_group("enemies"):
		area.die()
		if area.is_in_group("path"): Global.pathKills += 1
		if !Global.pathGot:
			if Global.pathKills >= 10:
				Global.achievements["pathKills"] = true
				get_parent().find_child("achieve").pitch_scale = 1.0 + randf_range(-0.7, 0.7)
				get_parent().find_child("achieve").play()
				Global.pathGot = true
		else: area.hitSound.play()
	if area.is_in_group("boss"): area.damaged()
	while area:
		await get_tree().create_timer(0.1).timeout
		if area: area.die()

func _on_homing_area_entered(area: Area2D) -> void:
	if area.is_in_group("fireball"): return
	if area.is_in_group("enemies"):
		area.die()
		if area.is_in_group("path"): Global.pathKills += 1
		if !Global.pathGot:
			if Global.pathKills >= 10:
				Global.achievements["pathKills"] = true
				get_parent().find_child("achieve").pitch_scale = 1.0 + randf_range(-0.7, 0.7)
				get_parent().find_child("achieve").play()
				Global.pathGot = true
		else: area.hitSound.play()
	if area.is_in_group("boss"): area.damaged()
	while area:
		await get_tree().create_timer(1.0).timeout
		if area: area.die()

@onready var upgrader = preload("res://scenes/upgrades.tscn").instantiate()
func _on_debug_visibility_changed() -> void:
	if not $Debug.visible: return
	var ab1 = $"Debug/Panel/CenterContainer/Container/Abilities/1/Ability1"
	var ab2 = $"Debug/Panel/CenterContainer/Container/Abilities/2/Ability2"
	var ab3 = $"Debug/Panel/CenterContainer/Container/Abilities/3/Ability3"
	var ab4 = $"Debug/Panel/CenterContainer/Container/Abilities/4/Ability4"
	var ab5 = $"Debug/Panel/CenterContainer/Container/Abilities/5/Ability5"
	var ab6 = $"Debug/Panel/CenterContainer/Container/Abilities/6/Ability6"
	var ab7 = $"Debug/Panel/CenterContainer/Container/Abilities/7/Ability7"
	var ab8 = $"Debug/Panel/CenterContainer/Container/Abilities/8/Ability8"
	ab1.clear()
	ab2.clear()
	ab3.clear()
	ab4.clear()
	ab5.clear()
	ab6.clear()
	ab7.clear()
	ab8.clear()
	for upgrade in upgrader.upgrades:
		ab1.add_item(upgrade.ID)
		ab2.add_item(upgrade.ID)
		ab3.add_item(upgrade.ID)
		ab4.add_item(upgrade.ID)
		ab5.add_item(upgrade.ID)
		ab6.add_item(upgrade.ID)
		ab7.add_item(upgrade.ID)
		ab8.add_item(upgrade.ID)
	ab1.select(-1)
	ab2.select(-1)
	ab3.select(-1)
	ab4.select(-1)
	ab5.select(-1)
	ab6.select(-1)
	ab7.select(-1)
	ab8.select(-1)
	for i in range(len(UpgradeManager.equippedUpgrades)):
		var ab = $Debug/Panel/CenterContainer/Container/Abilities.find_child(str(i + 1)).find_child("Ability" + str(i + 1))
		if not ab: return
		for item_index in range(ab.item_count):
			if ab.get_item_text(item_index) == UpgradeManager.equippedUpgrades[i]["ID"]: ab.select(item_index) ; break

func _on_back_pressed() -> void: $Debug.hide() ; get_tree().paused = false

func _update_equipped() -> void:
	$"../backgroudMusic".process_mode = Node.PROCESS_MODE_ALWAYS if Global.playWhilePaused else Node.PROCESS_MODE_INHERIT
	for i in range(8):
		var ab = $Debug/Panel/CenterContainer/Container/Abilities.find_child(str(i + 1)).get_child(0)
		if ab.selected == -1: continue
		for upgrade in upgrader.upgrades:
			if upgrade.ID == ab.get_item_text(ab.selected):
				var data = {"Type": upgrade.type, "ID": upgrade.ID, "Rarity": upgrade.rarity, "Icon": upgrade.icon, "Infused": $Debug/Panel/CenterContainer/Container/Abilities.find_child(str(i + 1)).get_child(1).button_pressed}
				if i < UpgradeManager.equippedUpgrades.size(): UpgradeManager.equippedUpgrades[i] = data
				else: UpgradeManager.equippedUpgrades.append(data)
				break
	_on_back_pressed()

func _on_pew_area_entered(area: Area2D) -> void:
	for group in area.get_groups(): if group not in ["path", "enemies", "dodge", "boss", "asteroid"]: return
	if area.has_method("die"): area.die()
	elif area.has_method("death"): area.death()
	elif area.has_method("dead"): area.dead()
	elif area.has_method("damaged"): area.damaged()
	else: area.queue_free()
