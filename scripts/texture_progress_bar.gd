extends TextureProgressBar

@onready var timer = $Timer

func _ready():
	min_value = 0
	max_value = 1

func _physics_process(delta):
	if timer.is_stopped():
		value = max_value
	if not timer.is_stopped():
		value = 0
