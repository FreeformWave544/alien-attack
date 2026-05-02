extends Control

@onready var score = $Score
@onready var livesLeft = $Lives
@onready var time: Label = $Time

func _ready() -> void:
	$Difficulty.text = str(Global.difficil) + " MODE"
	set_upgrades()

func set_score_label():
	score.text = "SCORE: " + str(Global.score)
	set_upgrades()

func set_lives(amount):
	livesLeft.text = str(amount)
	set_upgrades()

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		process_mode = Node.PROCESS_MODE_ALWAYS
		get_tree().paused = !get_tree().paused
		$"../paused".visible = !$"../paused".visible

func set_upgrades():
	var equipped = UpgradeManager.equippedUpgrades
	if !equipped: return
	var children = $Upgrades.get_children()
	for idx in children.size():
		if idx < equipped.size():
			children[idx].texture = equipped[idx]["Icon"]
