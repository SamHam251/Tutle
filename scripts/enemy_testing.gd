extends CharacterBody2D
class_name Enemy
var in_range = false
@export var health = 1000
var knockback_vel = Vector2.ZERO
var move = 15

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

#this is all for parrying and stuff
func _process(delta: float) -> void:
	if in_range == true:
		if Global.parry == true and Global.parried == false:
			Global.parried = true
			print("PARRY TEST")
			
#this is for the walking, jumping, gravity, and the knockback
func _physics_process(delta: float) -> void:
	
	knockback_vel = knockback_vel.move_toward(Vector2.ZERO, 800.0*delta)
	velocity = knockback_vel
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()

#this just determines if your in range to parry the monster
func _on_hurtbox_body_entered(_body: Node2D) -> void:
	in_range = true

#this just determines if your out range to parry the monster
func _on_hurtbox_body_exited(_body: Node2D) -> void:
	in_range = false

#this is the damaging enemies function which lets you combo enemies
func take_damage(damage, knockback):
	health -= damage
	print(health)
	knockback_vel = knockback
	print("Knockback passed in: ", knockback)
	if health <= 0:
		queue_free()
