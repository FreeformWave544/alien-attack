extends Area2D

@onready var fb = preload("res://scenes/fireball.tscn")
@onready var enemy = preload("res://scenes/enemy.tscn")
@onready var sprite = $AnimatedSprite2D
@onready var tractor_beam = $TractorBeam
@onready var player = get_tree().get_first_node_in_group("player")
@onready var count = 0
var attacking = false
var tractor_beam_active = false
var score_drain_timer = 0
var tractor = 0

func _ready():
	attackLoop()
	change_frame_loop()
	start()
	$"big boom".visible = false
	tractor_beam.visible = false
	tractor_beam.pivot_offset = Vector2(0, 100)

func _process(delta):
	if tractor_beam_active and player:
		var start_pos = global_position - Vector2(0,-125)
		var end_pos = player.global_position - Vector2(0,-125)
		var dir = end_pos - start_pos
		tractor_beam.global_position = start_pos
		tractor_beam.size = Vector2(dir.length(), 200)
		tractor_beam.rotation = dir.angle()
		score_drain_timer += delta
		if score_drain_timer == 5.0:
			score_drain_timer = 0
			tractor += 1
			Global.addScore += 2
			if tractor == 20:
				tractor_beam_active = false

func start():
	while global_position.x != 1110:
		global_position.x -= 10
		await get_tree().create_timer(0.1).timeout

func change_frame_loop():
	while true:
		await get_tree().create_timer(0.2).timeout
		sprite.frame = count
		count += 1
		if count >= 4:
			count = 0

func attackLoop():
	var attack
	while true:
		await get_tree().create_timer(1).timeout
		while not attacking:
			await get_tree().create_timer(3).timeout
			attack = randi_range(1, 4)
			if attack == 1:
				print(attack)
				firstAttack()
			elif attack == 2:
				print(attack)
				secondAttack()
			elif attack == 3:
				print(attack)
				activate_tractor_beam()
			elif attack == 4:
				print(attack)
				thirdAttack()

func firstAttack():
	if Global.died:
		attacking = true
		create_expanding_circle()
		for e in range(5):
			var gap = randi_range(1, 9)
			var otherGap = gap + 1
			await get_tree().create_timer(4).timeout
			var pos = Vector2(1000, 50)
			for i in range(13):
				if i != gap and i != otherGap:
					var enemyInstance = enemy.instantiate()
					$enemyContainer.add_child(enemyInstance)
					enemyInstance.global_position = pos
					enemyInstance.add_to_group("dodge")
				pos += Vector2(0, 70)
		attacking = false
		Global.canFire = true

func secondAttack():
	var fireball = fb.instantiate()
	add_child(fireball)
	fireball.add_to_group("fireball")
	fireball.animator.play("default")
	fireball.global_position = global_position
	var viewport_height = get_viewport_rect().size.y
	var top_bound = -20
	var bottom_bound = viewport_height - 20
	fireball.global_position.y = randi_range(top_bound, bottom_bound)

func thirdAttack():
	var fireball = fb.instantiate()
	add_child(fireball)
	fireball.add_to_group("fireball")
	fireball.animator.play("default")
	fireball.global_position = global_position
	fireball.global_position.y = player.global_position.y

func activate_tractor_beam():
	if not player:
		print("Error: Player node not found!")
		return
	tractor_beam.visible = true
	tractor_beam_active = true
	attacking = true
	while tractor_beam_active:
		tractor_beam.global_position = player.global_position
		Global.addScore -= 50
		await get_tree().create_timer(1).timeout

func deactivate_tractor_beam():
	tractor_beam.visible = false
	tractor_beam_active = false
	attacking = false

func damaged():
	sprite.frame = 5
	Global.bossLives -= 1
	if Global.bossLives <= 0:
		died()

func create_expanding_circle():
	Global.canFire = false
	var circle = ColorRect.new()
	circle.color = Color(1, 1, 1, 1)
	circle.size = Vector2(10, 10)
	circle.position = Vector2(200, 0)
	circle.pivot_offset = Vector2(circle.size.x, circle.size.y / 2)
	add_child(circle)
	var shader_material = ShaderMaterial.new()
	shader_material.shader = preload("res://circle_shader.tres")
	circle.material = shader_material
	var screen_size = get_viewport_rect().size
	var max_size = screen_size.x * 3
	var tween = get_tree().create_tween()
	tween.tween_property(circle, "size", Vector2(max_size, max_size), 1.2)
	tween.parallel().tween_property(circle, "position", Vector2(-max_size, -max_size / 2), 1.2)
	tween.parallel().tween_property(circle, "modulate:a", 0, 1.2)
	await tween.finished
	circle.queue_free()

func died():
	var smallBoomPos = Vector2(randi_range(-50, 50), randi_range(-100, 100))
	var smallBoom = $"small boom"
	for i in range(20):
		sprite.frame = 5
		smallBoomPos = Vector2(randi_range(-50, 50), randi_range(-100, 100))
		smallBoom.position = smallBoomPos
		smallBoom.play("default")
		await get_tree().create_timer(0.3).timeout
		smallBoom.position = Vector2(randi_range(-50, 50), randi_range(-150, 150))
		smallBoom.play("default")
		sprite.frame = 4
	await get_tree().create_timer(1.8).timeout
	$AnimatedSprite2D.visible = false
	$"big boom".visible = true
	$"big boom".play("default")
	await get_tree().create_timer(1.6).timeout
	queue_free()
	Global.addScore += randi_range(7, 20) * 100
	Global.isBoss = false
	Global.canFire = true
