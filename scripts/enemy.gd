extends Area2D

signal died

@onready var aniSprite = $AnimatedSprite2D
@onready var hitSound = $EnemyHitSound
@export var speed = 300
var is_dead = false 

func _ready() -> void:
	aniSprite.visible = false

func _physics_process(delta):
	if not is_dead:
		global_position.x += -speed * delta

func die():
	if is_dead:
		return
	is_dead = true
	Global.addScore += 100
	aniSprite.visible = true
	$Sprite2D.visible = false
	aniSprite.play("default")
	remove_child($CollisionShape2D) ; remove_child($CollisionShape2D2) ; remove_child($CollisionShape2D3)
	await get_tree().create_timer(1).timeout
	if not is_in_group("path"):
		queue_free()

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage()
	die()
