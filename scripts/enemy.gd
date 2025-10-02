extends Area2D
class_name Enemy
signal died

@onready var aniSprite = $AnimatedSprite2D
@onready var hitSound = $EnemyHitSound
@export var speed := 300.0
@export var health := 1.0
var constantSpeed := speed
var is_dead := false 
 
func _ready() -> void:
	aniSprite.visible = false
	$EnemyHitSound.volume_db = Global.volume - 30

func _physics_process(delta):
	if not is_dead:
		global_position.x += -speed * delta

func damage(dmg: float = 1):
	health -= dmg
	if health <= 0:
		die()

func die():
	if is_dead:
		return
	is_dead = true
	Global.addScore += 100
	aniSprite.visible = true
	$Sprite2D.visible = false
	aniSprite.play("default")
	remove_child($CollisionShape2D) ; remove_child($CollisionShape2D2)
	await get_tree().create_timer(1.5).timeout
	if not is_in_group("path"):
		queue_free()

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage()
	die()

func set_speed_multiplier(mult):
	if mult is bool and mult == false: speed = constantSpeed ; return
	elif mult is int or mult is float: speed = constantSpeed * mult
