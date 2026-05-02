extends Control

var pi_digits = "3.14159265358979323846264338327950288419716939937510582097494459230"
var time_left = 20  # 20 seconds timer
var timer = Timer.new()
var text_edit : TextEdit  # Reference to TextEdit

func _ready():
	add_child(timer)
	timer.wait_time = 1  # 1-second intervals
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	timer.start()
	text_edit = $Panel/TextEdit
	text_edit.custom_minimum_size = Vector2(580, 100)  # Set size using custom_minimum_size
	text_edit.text = ""
	add_child(text_edit)
	text_edit.position = Vector2(0, 50)

func _on_timer_timeout():
	time_left -= 1
	if time_left <= 0:
		check_answer()

func check_answer():
	var input_text = text_edit.text.strip_edges()
	var volume_increase = 0
	for i in range(min(input_text.length(), pi_digits.length())):
		if input_text[i] == pi_digits[i]:
			volume_increase += 1
	Global.volume = volume_increase
	_back()

func _back():
	Global.transition("res://scenes/start_screen.tscn")
