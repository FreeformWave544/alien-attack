extends Area2D

@export var speed = 120
@onready var visible_notifier = $VisibleNotifier
@onready var hitSound = $EnemyHitSound
@onready var achieveSound = $achieve
@onready var bossDamagable = true

func _ready():
	visible_notifier.connect("screen_exited", _on_screen_exited)
	$EnemyHitSound.volume_db = Global.volume - 30

func _physics_process(delta):
	global_position.x += speed*delta

func _on_screen_exited():
	queue_free()

func _on_area_entered(area):
	if not area.is_in_group("fireball"):
		if area.is_in_group("enemies"):
			area.die()
			if area.is_in_group("path"):
				Global.pathKills += 1
			if !Global.pathGot:
				if Global.pathKills == 10:
					Global.achievements["pathKills"] = true
					Global.achieveSoundPlay = true
					Global.pathGot = true
			else:
				area.hitSound.play()
			queue_free()
		if area.is_in_group("boss"):
			if bossDamagable == true:
				area.damaged()
				queue_free()
				bossDamagable = false
				await get_tree().create_timer(2).timeout
				bossDamagable = true
	else:
		queue_free()
