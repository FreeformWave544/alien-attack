extends Path2D

@onready var hitSound = $PathFollow2D/Enemy/EnemyHitSound
@onready var pathfollow = $PathFollow2D
@onready var enemy = $PathFollow2D/Enemy
@export var paths: Array[Curve2D]

func _ready() -> void:
	var curved = randi_range(0,3)
	curve = paths[curved]
	pathfollow.set_progress_ratio(0)

func _process(delta: float) -> void:
	if !enemy:
		return
	if not enemy.is_dead:
		pathfollow.progress_ratio += 0.15 * delta
		#if pathfollow.progress >= 1:
			#queue_free() 
	else:
		await get_tree().create_timer(1).timeout
		queue_free()
