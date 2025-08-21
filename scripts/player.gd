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

func start_fade_in():
	fading_in = 1

func start_fade_out():
	fading_in = -1

func _physics_process(delta):
	velocity = Vector2(0,0)
	if Input.is_action_pressed("move_right"):
		velocity.x = speed
	if Input.is_action_pressed("move_left"):
		velocity.x = -speed
	if Input.is_action_pressed("move_up"):
		velocity.y = -speed
	if Input.is_action_pressed("move_down"):
		velocity.y = speed
	move_and_slide()
	var screen_size = get_viewport_rect().size
	global_position = global_position.clamp(Vector2(0,0), screen_size)

func shoot():
	if timer.time_left == 0 and Global.canFire:
		var rocket_instance = rocket_scene.instantiate()
		rocket_container.add_child(rocket_instance)
		rocket_instance.global_position = global_position
		rocket_instance.global_position.x += 80
		timer.one_shot = true
		timer.start()
		laser.play()

func take_damage(v := 1):
	Global.TakeLIVES += v

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

func move_up(v := true):
	while v == true: 
		Input.action_press("move_up")
		await get_tree().process_frame
	Input.action_release("move_up")

func move_down(v := true):
	while v == true: 
		Input.action_press("move_down")
		await get_tree().process_frame
	Input.action_release("move_down")

func move_left(v := true):
	while v == true: 
		Input.action_press("move_left")
		await get_tree().process_frame
	Input.action_release("move_left")

func move_right(v := true):
	while v == true: 
		Input.action_press("move_right")
		await get_tree().process_frame
	Input.action_release("move_right")
