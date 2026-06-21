extends Panel

var entered = false
func _on_mouse_entered() -> void:
	entered = true
	while $Background.scale.x < 1.23 and entered:
		$Background.scale = lerp($Background.scale, Vector2(1.25, 1.25), 0.1)
		await get_tree().process_frame
	$Background.scale = Vector2(1.25, 1.25)
	entered = false

func _on_mouse_exited() -> void:
	entered = false
	while $Background.scale.x > 1.05 and not entered:
		$Background.scale = lerp($Background.scale, Vector2(1.0, 1.0), 0.1)
		await get_tree().process_frame
	$Background.scale = Vector2(1.0, 1.0)
