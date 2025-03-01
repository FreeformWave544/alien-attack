extends Area2D

@onready var fb = preload("res://scenes/fireball.tscn")
@onready var enemy = preload("res://scenes/enemy.tscn")
@onready var sprite = $AnimatedSprite2D
@onready var count = 0
var attacking = false

func _ready():
	attackLoop()
	change_frame_loop()
	start()

func start():
	print(global_position)
	while global_position.x != 1110:
		global_position.x -= 10
		await get_tree().create_timer(0.2).timeout
		print(global_position)

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
			attack = randi_range(1,4)
			if attack == 1:
				print(attack)
				firstAttack()
			elif attack >= 2:
				print(attack)
				secondAttack()

func firstAttack():
	if Global.died:
		attacking = true
		create_expanding_circle()
		for e in range(5):
			var gap = randi_range(1,9)
			var otherGap = gap + 1
			await get_tree().create_timer(4).timeout
			var pos = Vector2(1000,50)
			for i in range(13):
				if i != gap and i != otherGap:
					var enemyInstance = enemy.instantiate()
					$enemyContainer.add_child(enemyInstance)
					enemyInstance.global_position = pos
					enemyInstance.add_to_group("dodge")
				pos += Vector2(0,65)
		attacking = false
		Global.canFire = true

func secondAttack():
	var fireball = fb.instantiate()
	add_child(fireball)
	fireball.add_to_group("fireball")
	fireball.animator.play("default")
	fireballMove(fireball)

func fireballMove(fireball):
	while true:
		fireball.global_position.x -= 40
		await get_tree().create_timer(0.2).timeout

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
	for i in range(20):
		sprite.frame = 5
		await get_tree().create_timer(0.3).timeout
		sprite.frame = 4
	await get_tree().create_timer(1.8).timeout
	create_expanding_circle()
	queue_free()
	Global.addScore += randi_range(7,20) * 100
	Global.isBoss = false
	Global.canFire = true
