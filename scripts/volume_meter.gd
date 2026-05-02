extends Control

var pi_digits = "3.14159265358979323846264338327950288419716939937510582097494459230"
var time_left = 20
var timer = Timer.new()
@onready var text_edit = $Panel/TextEdit

func _ready():
	add_child(timer)
	timer.wait_time = 1
	timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	timer.start()
	text_edit.custom_minimum_size = Vector2(580, 100)
	text_edit.text = ""
	add_child(text_edit)
	text_edit.position = Vector2(0, 50)

func _on_timer_timeout():
	time_left -= 1
	if time_left <= 0: check_answer()

func check_answer():
	var input_text = text_edit.text.strip_edges()
	var volume_increase = 0
	for i in range(min(input_text.length(), pi_digits.length())):
		if input_text[i] == pi_digits[i]: volume_increase += 1
	Global.volume = volume_increase
	_back()

func _back(): Global.transition("res://scenes/start_screen.tscn")
