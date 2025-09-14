extends Node2D

signal enemy_spawned(enemy_instance)

var enemy_scene = preload("res://scenes/enemy.tscn")
var path_enemy_scene = preload("res://scenes/path_enemy.tscn")
var asteroid = preload("res://scenes/asteroids.tscn")
var time_passed := 0.0
var value = 0.0
@onready var game_script = get_parent()
@export var path_chance: int = 4
@export var asteroid_chance: int = 1
@onready var enemy_container = $SpawnPositions
@onready var timer = $Timer

func _on_timer_timeout() -> void:
	if Global.isBoss:
		return
	# Scale spawn rate with value (lower value = slower spawn)
	var spawn_rate = randf_range(0.2, 6.6) * (1.0 - value * 0.1)
	timer.wait_time = clamp(spawn_rate, 0.4, 6.6)  # Ensure reasonable spawn time
	timer.one_shot = true
	timer.start()
	match Global.difficil:
		"hard":
			path_chance = 4
			asteroid_chance = clamp(300 - int(value * 5), 50, 300)
		"easy":
			path_chance = 16
			asteroid_chance = clamp(100 - int(value * 2), 30, 100)
		_:
			path_chance = 8
			asteroid_chance = clamp(200 - int(value * 3), 40, 200)

	if randi_range(1, asteroid_chance) == 1:
		ASTEROID()
		return
	var norm_path = randi_range(1, path_chance)
	var enemy_instance: Node2D

	if norm_path == 2:
		enemy_instance = path_enemy_scene.instantiate()
		enemy_instance.add_to_group("path")
	else:
		enemy_instance = enemy_scene.instantiate()
		enemy_instance.global_position = Vector2(1400, randi_range(15, 720))
	var enemy_health = 100 + value * 10 
	var enemy_speed = 100 + value * 10

	enemy_instance.set("health", enemy_health)
	enemy_instance.set("speed", enemy_speed)
	enemy_instance.connect("died", Callable(game_script, "_on_enemy_died"))
	
	enemy_container.add_child(enemy_instance)
	emit_signal("enemy_spawned", enemy_instance)

func _process(delta):
	time_passed += delta
	value = $DifficultyCurve.difficulty_curve.sample(time_passed)

func ASTEROID():
	var asteroid_instance = asteroid.instantiate()
	asteroid_instance.global_position = Vector2(1668, randf_range(-873.00, 1548.00))
	add_child(asteroid_instance)
