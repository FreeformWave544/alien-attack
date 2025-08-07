extends ParallaxBackground

@export var scrollSpeed := 40.0

func _process(delta: float) -> void:
	scroll_offset.x -= scrollSpeed * delta
	scroll_offset.y -= (scrollSpeed / 2) * delta
