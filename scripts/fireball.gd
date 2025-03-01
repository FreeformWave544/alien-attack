extends Area2D

@onready var animator = $AnimatedSprite2D

func _ready() -> void:
	animator.play("moving")

func blow():
	await animator.play("explosion")
	queue_free()
