extends CharacterBody2D

# basic movement
const SPEED = Vector2(300.0, 250.0)
const ACCELERATION = Vector2(10.0, 15.0)

# enemy AI variables
var target = null
var hover_target = Vector2(0, 0)
var target_in_hover_range = false
var attacking = false
const ATTACK_WINDUP = 0.4

# hovering
@onready var max_hover_raycast = $MaxHoverHeight  # hover_raycast.is_colliding()
@onready var min_hover_raycast = $MinHoverHeight

# timers
@onready var action_timer = $Timers/ActionTimer
@onready var attack_timer = $Timers/AttackTimer

func _physics_process(delta: float) -> void:
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		action()
	
	if attacking:
		velocity.x = move_toward(velocity.x, 0, ACCELERATION.x)
		velocity.y = move_toward(velocity.y, 0, ACCELERATION.y)
	else:
		hover_towards_target()

	move_and_slide()

func action() -> void:  # calls when ActionTimer reaches 0.
	print("action()")
	if target == null or action_timer.is_stopped(): return
	action_timer.stop()  # stop new actions from happening until the current one is finished
	
	# start spin attack
	attack_timer.start(ATTACK_WINDUP)

func start_attack() -> void:  # calls when AttackTimer reaches 0.
	print("start_attack()")
	pass # Replace with function body.

func hover_towards_target() -> void:
	# print(target_in_hover_range)
	if target == null: return
	
	# X-axis: move towards target if they are outside of hover rect, move away if they are in the rect
	var dir = sign(position.x - target.position.x)  # positive if to the right of target, negative otherwise
	if target_in_hover_range:
		# move away from target
		velocity.x = move_toward(velocity.x, SPEED.x * dir, ACCELERATION.x)
		pass
	else:
		# move towards target
		velocity.x = move_toward(velocity.x, SPEED.x * -dir, ACCELERATION.x)
		pass
	
	# Y-axis
	if not max_hover_raycast.is_colliding():
		# move towards ground if too high up
		velocity.y = move_toward(velocity.y, SPEED.y, ACCELERATION.y)
	elif min_hover_raycast.is_colliding():
		# move away from ground if too low
		velocity.y = move_toward(velocity.y, -SPEED.y, ACCELERATION.y)
	else:
		if target_in_hover_range:
			# move away from player
			velocity.y = move_toward(velocity.y, -SPEED.y, ACCELERATION.y)
		else:
			velocity.y = move_toward(velocity.y, SPEED.y, ACCELERATION.y)

func _on_detection_range_body_entered(body: Node2D) -> void:
	print([body.is_in_group("friendly"), target])
	if body.is_in_group("friendly") and target == null:
		target = body
		print("targeted")

func _on_hover_range_body_entered(body: Node2D) -> void:
	if body == target:
		target_in_hover_range = true

func _on_hover_range_body_exited(body: Node2D) -> void:
	if body == target:
		target_in_hover_range = false
