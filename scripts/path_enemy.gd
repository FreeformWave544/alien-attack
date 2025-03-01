extends Path2D

@onready var hitSound = $PathFollow2D/Enemy/EnemyHitSound
@onready var pathfollow = $PathFollow2D
@onready var enemy = $PathFollow2D/Enemy

func _ready() -> void:
	pathfollow.set_progress_ratio(1)

func _process(delta: float) -> void:
	if not enemy.is_dead:
		pathfollow.progress_ratio -= 0.25 * delta
		if pathfollow.progress <= 0:
			queue_free() 
	else:
		await get_tree().create_timer(1).timeout
		queue_free()
