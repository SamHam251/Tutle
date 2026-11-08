extends Node

const game_scene_path = "res://scenes/game.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func pressed_play() -> void:
	print("ay")
	get_tree().change_scene_to_file(game_scene_path)
