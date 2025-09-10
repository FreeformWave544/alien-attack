extends Control

@onready var score = $Score
@onready var livesLeft = $Lives
@onready var time: Label = $Time

func _ready() -> void:
	$Difficulty.text = str(Global.difficil) + " MODE"

func set_score_label(new_score):
	score.text = "SCORE: " + str(new_score)

func set_lives(amount):
	livesLeft.text = str(amount)

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		process_mode = Node.PROCESS_MODE_ALWAYS
		get_tree().paused = !get_tree().paused
		$"../paused".visible = !$"../paused".visible
