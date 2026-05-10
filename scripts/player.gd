extends CharacterBody2D
class_name Player
signal took_damage

var rocket_scene = preload("res://scenes/rocket.tscn")

@onready var laser = $Laser
@export var speed = 300
@onready var rocket_container = $RocketContainer
@onready var timer = $TextureProgressBar/Timer
@onready var easyview = $easyview
var fade_speed = 1.5
var fading_in = 0

func _ready():
	easyview.modulate.a = 0.0
	$plo.visible = false
	$plo.process_mode = Node.PROCESS_MODE_ALWAYS
	$Laser.volume_db = Global.volume - 30

func _process(delta):
	if Input.is_action_just_pressed("shoot"):
		shoot()
	if Global.difficil == "easy":
		if fading_in == 0:
			start_fade_in()
	if fading_in == 1:
		easyview.modulate.a = min(easyview.modulate.a + (delta * fade_speed), 1.0)
		if easyview.modulate.a >= 1.0:
			start_fade_out()
	elif fading_in == -1:
		easyview.modulate.a = max(easyview.modulate.a - (delta * (fade_speed+(fade_speed * 0.5))), 0.0)
		if easyview.modulate.a <= 0.0:
			start_fade_in()

func start_fade_in(): fading_in = 1

func start_fade_out(): fading_in = -1

var projSpeed = 500.0
func _physics_process(delta):
	projSpeed = 500.0 * delta
	velocity = Vector2(0,0)
	if Input.is_action_pressed("move_right"): velocity.x = speed
	if Input.is_action_pressed("move_left"): velocity.x = -speed
	if Input.is_action_pressed("move_up"): velocity.y = -speed
	if Input.is_action_pressed("move_down"): velocity.y = speed
	move_and_slide()
	var screen_size = get_viewport_rect().size
	global_position = global_position.clamp(Vector2(0,0), screen_size)

func shoot():
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
	$Surge.global_position = global_position
	$Surge.show()
	while $Surge.global_position.x < 1280.0:
		if get_tree().paused: continue
		$Surge.global_position.x += projSpeed
		await get_tree().process_frame
	for i in range(10):
		$Surge.modulate.a -= 0.1
		$Surge.global_position.x += 0.1
		await get_tree().process_frame
	$Surge.hide()
	$Surge.modulate.a = 1.0
	$Surge.global_position = Vector2(-150.0, 150.0)
	return true

func _homing_head():
	$Homing.global_position = global_position
	$Homing.show()
	var startTime := Time.get_unix_time_from_system()
	var targetEnemy = $"../EnemySpawner/SpawnPositions".get_children().pick_random()
	while Time.get_unix_time_from_system() - startTime <= 5.0:
		if get_tree().paused: continue
		if $Homing.global_position.x >= 1300.0: global_position.x -= 0.1 ; await get_tree().process_frame
		if len($"../EnemySpawner/SpawnPositions".get_children()) <= 0: $Homing.global_position.x += 0.1 ; await get_tree().process_frame
		if not targetEnemy: targetEnemy = $"../EnemySpawner/SpawnPositions".get_children().pick_random()
		$Homing.global_position.x = move_toward($Homing.global_position.x, targetEnemy.global_position.x, projSpeed) if targetEnemy else $Homing.global_position.x + 0.1
		$Homing.global_position.y = move_toward($Homing.global_position.y, targetEnemy.global_position.y, projSpeed) if targetEnemy else $Homing.global_position.y
		await get_tree().process_frame
	for i in range(10):
		$Homing.modulate.a -= 0.1
		await get_tree().process_frame
	$Homing.hide()
	$Homing.modulate.a = 1.0
	$Homing.global_position = Vector2(-150.0, 150.0)
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
	if area.is_in_group("boss"):
		area.damaged()

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
	if area.is_in_group("boss"):
		area.damaged()
