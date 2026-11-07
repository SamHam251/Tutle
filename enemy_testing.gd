extends Node2D
class_name Enemy
var in_range = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if in_range == true:
		if Global.parry == true and Global.parried == false:
			Global.parried = true
			print("PARRY TEST")
			
	pass



func _on_area_2d_body_entered(body: Node2D) -> void:
	in_range = true
	


func _on_area_2d_body_exited(body: Node2D) -> void:
	in_range = false
