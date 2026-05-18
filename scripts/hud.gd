extends Control

@onready var score = $Score
@onready var livesLeft = $Container/Lives
@onready var time: Label = $Time

func _ready() -> void:
	$Container/Difficulty.text = str(Global.difficil) + " MODE"
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
		$"../paused".visible = !$"../paused".visible
		$"../options".visible = $"../paused".visible
		get_tree().paused = $"../paused".visible
		$"../../backgroudMusic".process_mode = Node.PROCESS_MODE_ALWAYS if Global.playWhilePaused else Node.PROCESS_MODE_INHERIT

func set_upgrades():
	if len(UpgradeManager.equippedUpgrades) == 0:
		for guy in $Upgrades.get_children():
			guy.texture_progress = null
	var equipped = UpgradeManager.equippedUpgrades
	if !equipped: return
	var children = $Upgrades.get_children()
	for idx in children.size():
		if idx < equipped.size(): children[idx].texture_progress = equipped[idx]["Icon"]
