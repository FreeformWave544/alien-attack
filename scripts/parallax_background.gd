extends ParallaxBackground

@export var scrollSpeed := 40.0

func _enter_tree() -> void:
	scroll_offset = Global.scroll_offset

func _process(delta: float) -> void:
	scroll_offset.x -= scrollSpeed * delta
	scroll_offset.y -= (scrollSpeed / 2) * delta
