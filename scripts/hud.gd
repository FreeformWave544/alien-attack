extends Control

@onready var score = $Score
@onready var livesLeft = $Lives

func _ready() -> void:
	$Difficulty.text = str(Global.difficil) + " MODE"

func set_score_label(new_score):
	score.text = "SCORE: " + str(new_score)

func set_lives(amount):
	livesLeft.text = str(amount)
