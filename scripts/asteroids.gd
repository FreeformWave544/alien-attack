extends Area2D

var playerPos: Vector2 = Vector2(1668, -215)
var velocity: Vector2 = Vector2.ZERO
var speed: float = 200
var dying: bool = false

func _ready() -> void:
	shoot()

func shoot():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		playerPos = player.global_position
		var direction = (playerPos - global_position).normalized()
		velocity = direction * speed

func _physics_process(delta: float) -> void:
	if dying:
		return
	global_position += velocity * delta
	if global_position.y <= -1000:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.take_damage(5)
		playerContact(body)

func _on_area_entered(area: Area2D) -> void:
	if area is Enemy:
		area.is_dead = true
	await get_tree().process_frame
	area.queue_free()

func playerContact(body: Node2D):
	$Sprite.play("Explosion")

func contact():
	velocity *= 1.2
	await get_tree().create_timer(1).timeout
	queue_free()
