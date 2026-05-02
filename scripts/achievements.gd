extends Control

var medals = preload("res://scenes/medals/achievment_medals.tscn")
var achievements = Global.achievements

func _ready():
	if Global.achievements:
		for key in Global.achievements:
			if Global.achievements[key]:
				if key == Constants.PATHKILLS:
					achieve(1)
				elif key == Constants.EHIGH:
					achieve(2)
				elif key == Constants.HHIGH:
					achieve(3)
	else:
		$CanvasLayer/none.text = "No achievements :("

func achieve(i):
	var x = (i * 100) * 2.3
	var y = 200
	var medal = medals.instantiate()
	$CanvasLayer.add_child(medal)
	medal.animation = "default"
	medal.stop()
	medal.call_deferred("set", "frame", i - 1)
	await get_tree().process_frame
	medal.global_position = Vector2(x, y)
	medal.scale = Vector2(0, 0)
	get_tree().create_tween().tween_property(medal, "scale", Vector2(0.6, 0.6), 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	var area = Area2D.new()
	area.global_position = medal.global_position
	$CanvasLayer.add_child(area)
	var shape = RectangleShape2D.new()
	var texture = medal.sprite_frames.get_frame_texture(medal.animation, medal.frame)
	if texture:
		var texture_size = texture.get_size()
		shape.extents = texture_size / 2
	else:
		print("No texture found for medal frame ", medal.frame)
	var collision = CollisionShape2D.new()
	collision.shape = shape
	area.add_child(collision)
	area.mouse_entered.connect(func(): show_tooltip(i, medal.global_position))
	area.mouse_exited.connect(func(): hide_tooltip(i))

func show_tooltip(i, pos):
	var achievement = $CanvasLayer.get_node("ach" + str(i))
	achievement.visible = true
	achievement.global_position = Vector2(pos.x - 70, pos.y + 100)
	achievement.modulate = Color(1, 1, 1, 0)
	get_tree().create_tween().tween_property(achievement, "modulate", Color(1, 1, 1, 1), 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)

func hide_tooltip(i):
	var achievement = $CanvasLayer.get_node("ach" + str(i))
	var t = get_tree().create_tween()
	t.tween_property(achievement, "modulate", Color(1, 1, 1, 0), 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await t.finished
	achievement.visible = false

func _on_back_pressed() -> void:
	Global.transition("res://scenes/start_screen.tscn")

func _on_button_pressed() -> void:
	Global.achievements[Constants.PATHKILLS] = true
	Global.achievements[Constants.HHIGH] = true
	Global.achievements[Constants.EHIGH] = true
