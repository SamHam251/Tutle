extends Control

@onready var background = $NinePatchRect
@onready var Healthbar = $NinePatchRect/AspectRatioContainer/TextureProgressBar
@onready var ScoreLabel = $NinePatchRect/ScoreLabel
@onready var KillsLabel = $NinePatchRect/KillsLabel

var entities_near_ui = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	Healthbar.value = Global.player_health
	if Global.score <= 99999:
		var score_text = "Score: %d"
		ScoreLabel.text = score_text % Global.score
	else:
		ScoreLabel.text = "Score: A LOT"
	if Global.kills <= 999:
		var kills_text = "Kills: %d"
		KillsLabel.text = kills_text % Global.kills
	else:
		KillsLabel.text = "Kills: wtf"
	
	if entities_near_ui > 0:
		background.modulate = Color(1, 1, 1, move_toward(background.modulate[3], 0.2, 0.01))
	else:
		background.modulate = Color(1, 1, 1, move_toward(background.modulate[3], 1, 0.01))

func entity_too_close(area: Area2D) -> void:  # called when an enemy or player enters the area2D attached to the ui.
	entities_near_ui += 1

func reset_opacity(area: Area2D) -> void:  # called when the enemy/player leaves the area
	entities_near_ui -= 1
