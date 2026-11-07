extends CharacterBody2D

const SPEED = 500.0
const JUMP_VELOCITY = -250.0
const DASH_SPEED = 700.0
const ACCELERATION = 15.0
const ACTION_COOLDOWN_MIN = 45.0
const ACTION_COOLDOWN_MAX = 120.0

# enemy AI variables
var target = null
var target_in_dash_range = false
var action_timer = 0

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	# if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		# dash_at_target()
	
	if target == null:
		pass
	else:
		move_to_target()
		
		if action_timer <= 0:
			action_timer = do_action()
		else:
			action_timer -= 1

	move_and_slide()

func move_to_target() -> void:
	if target == null: return  # shouldn't happen but doesn't hurt to be safe.
	if target.position.x > self.position.x:
		velocity.x = move_toward(velocity.x, SPEED, ACCELERATION)
	elif target.position.x < self.position.x:
		velocity.x = move_toward(velocity.x, -SPEED, ACCELERATION)
	else:
		velocity.x = move_toward(velocity.x, 0, ACCELERATION)

func do_action() -> int:
	if target == null: return 0  # should never happen
	
	# if target is in dash range (i.e. near the ground), and the enemy is on the ground, do a dash and then reset the action timer
	# an extra condition is added to only dash once we have enough momentum in the direction we're moving in
	if target_in_dash_range and is_on_floor() and (sign(velocity.x) == sign(target.position.x - self.position.x)):
		dash_at_target()
		return randi_range(ACTION_COOLDOWN_MIN, ACTION_COOLDOWN_MAX)
	
	# if no action was done, return 0 (since an action wasn't done)
	return 0

func dash_at_target() -> void:
	if target == null: return
	if target.position.x - self.position.x > 0:
		velocity.x = DASH_SPEED
	else:
		velocity.x = -DASH_SPEED
	velocity.y = JUMP_VELOCITY

func _on_detection_range_body_entered(body: Node2D) -> void:
	# print("thing")
	if body.is_in_group("friendly"):
		target = body
		print(target)

func _on_dash_range_body_entered(body: Node2D) -> void:
	print("target in dash range")
	target_in_dash_range = true

func _on_dash_range_body_exited(body: Node2D) -> void:
	print("target left dash range")
	target_in_dash_range = false
