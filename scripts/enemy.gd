extends Area2D
class_name Enemy
signal died

@onready var aniSprite = $AnimatedSprite2D
@onready var hitSound = $EnemyHitSound
@onready var constantSpeed := speed
@export var speed := 300.0
@export var health := 1.0
var is_dead := false 
@onready var game = get_parent().get_parent().get_parent()
 
func _ready() -> void:
	aniSprite.visible = false
	$EnemyHitSound.volume_db = Global.volume - 30

func _physics_process(delta):
	if not is_dead:
		global_position.x += -speed * delta
		if is_in_group("path"): return
		$Sprite2D.flip_v = false if speed > 0 else true

func damage(dmg: float = 1):
	health -= dmg
	if health <= 0: die()
 
func flash():
	var tempMod = modulate
	modulate = Color(3.294, 3.294, 3.294, 1.0)
	await get_tree().create_timer(0.1).timeout
	modulate = tempMod

func die():
	health -= 150
	if not (health <= 0.0): flash() ; return
	if is_dead: return
	is_dead = true
	if not is_in_group("path") and $Sprite2D.flip_v == false and game and game.name == "Game" and game.walking_dead_active:
		get_parent().get_parent().get_parent().walking_dead_pool.append(global_position)
		var deadMark := preload("res://scenes/dead_marker.tscn").instantiate()
		get_parent().get_parent().add_child(deadMark, true)
		deadMark.global_position = global_position
	Global.addScore += 100
	aniSprite.visible = true
	$Sprite2D.visible = false
	aniSprite.play("default")
	remove_child($CollisionShape2D) ; remove_child($CollisionShape2D2)
	await get_tree().create_timer(0.75).timeout
	if not is_in_group("path"): queue_free()

func _on_body_entered(body):
	if body.has_method("take_damage"): body.take_damage()
	die()

func set_speed_multiplier(mult):
	if mult is bool and mult == false: speed = constantSpeed ; return
	elif mult is int or mult is float: speed = constantSpeed * mult

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies") and area.find_child("Sprite2D").flip_v == true: die()
