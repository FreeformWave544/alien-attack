extends Area2D

@onready var animator = $AnimatedSprite2D

func _ready() -> void:
	animator.play("moving")
