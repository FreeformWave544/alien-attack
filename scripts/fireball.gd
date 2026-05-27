extends Area2D

@onready var animator = $AnimatedSprite2D
var alive: bool = true
var hit: bool = false
var fbLives: int = 1

func _ready() -> void:
	animator.play("moving")
	match Global.difficil:
		"hard": fbLives = 1
		"easy": fbLives = 1
		_: fbLives = 2

func _process(delta: float) -> void:
	if not hit:
		global_position.x -= 5

func blow():
	animator.play("explosion")
	alive = false
	await get_tree().create_timer(1).timeout
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("start_fade_in"):
		hit = true
		animator.play("explosion")
		await get_tree().create_timer(1).timeout
		queue_free()
		Global.TakeLIVES += fbLives
