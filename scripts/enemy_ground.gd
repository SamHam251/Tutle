extends Enemy

const SPEED = 200.0
const ACCELERATION = 30.0
@onready var HOVER_RANGE: int = $DashRange/CollisionShape2D.shape.size.x  # this should never change but I can't make it a constant :(

# enemy AI variables
var target = null
var hover_target = 0  # target.position.x - HOVER_RANGE / 2
var target_in_dash_range = false

# indicator and hitboxes
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var dash_hitbox: Area2D = $HitboxDash

# timers
@onready var action_timer = $Timers/ActionTimer
@onready var dash_timer = $Timers/DashTimer
@onready var dash_end_timer = $Timers/DashEndTimer
@onready var stun_timer = $Timers/StunTimer
const ACTION_COOLDOWN_MIN = 1.0  # time in seconds
const ACTION_COOLDOWN_MAX = 3.0  # time in seconds

# dash-specific variables
const DASH_SPEED = 1300.0
const DASH_WINDUP = 0.4  # time in seconds between a dash being indicated and a dash happening
const JUMP_VELOCITY = -200.0
const DASH_TIME = 0.5
var is_attacking = false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if target != null or stun_timer.is_stopped():
		# AI when there is a target
		move_to_target()
	else:
		velocity.x = move_toward(velocity.x, 0, ACCELERATION)
	move_and_slide()

func move_to_target() -> void:
	# more accurately, the enemy will hover around the target to keep it just barely in the DashRange collider.
	if target == null or not stun_timer.is_stopped(): return  # shouldn't happen but doesn't hurt to be safe. this stops the function if there is no target
	
	# sign(position.x - target.position.x) is positive if the player is on the right, and negative if the player is on the left.
	hover_target = target.position.x + (HOVER_RANGE * 0.6 * sign(position.x - target.position.x))
	
	if hover_target > position.x:  # hover around the left side
		velocity.x = move_toward(velocity.x, SPEED, ACCELERATION)
	elif hover_target < position.x:  # hover around the right side
		velocity.x = move_toward(velocity.x, -SPEED, ACCELERATION)
	else:
		velocity.x = move_toward(velocity.x, 0, ACCELERATION)
	if is_attacking == false:
		if velocity.x > 0:
				sprite.flip_h = false
				sprite.play("idle")
		else:
			sprite.flip_h = true
			sprite.play("idle")
func dash_at_target() -> void:  # this function only PREPARES the dash and makes the indicator. (see _on_dash_timer_timeout()).
	is_attacking = true
	if target == null or not stun_timer.is_stopped(): return
	sprite.play("attack")
	sprite.modulate = Color(3, 3, 3, 1)
	dash_timer.start(DASH_WINDUP)
	await sprite.animation_finished
	is_attacking = false
	# print("dash queued")

func _on_action_timer_timeout() -> void:  # do action function
	if target == null or not dash_timer.is_stopped():  # don't queue an action if there is no target or if another is already happening
		action_timer.start(0.1)
		return
	
	# print("Action")

	# if target is in dash range (i.e. near the ground), and the enemy is on the ground, do a dash
	if target_in_dash_range and is_on_floor() and stun_timer.is_stopped():
		dash_at_target()
		action_timer.stop()  # this will be restarted after the dash is complete
	
	# if no action was done
	action_timer.start(randf_range(ACTION_COOLDOWN_MIN, ACTION_COOLDOWN_MAX))

func _on_dash_timer_timeout() -> void:  # timer starts when a dash is queued. this executes the dash
	if target == null: return
	
	sprite.modulate = Color(1, 1, 1, 1)
	
	if target.position.x - self.position.x > 0:
		velocity.x = DASH_SPEED
		dash_hitbox.scale.x = 1
	else:
		velocity.x = -DASH_SPEED
		dash_hitbox.scale.x = -1
	velocity.y = JUMP_VELOCITY
	
	dash_hitbox.monitorable = true
	dash_end_timer.start(DASH_TIME)
	
	action_timer.start(randf_range(ACTION_COOLDOWN_MIN, ACTION_COOLDOWN_MAX))

func _on_detection_range_body_entered(body: Node2D) -> void:
	print([body.is_in_group("friendly"), target])
	if body.is_in_group("friendly") and target == null:
		target = body
		print("targeted")

func _on_dash_range_body_entered(body: Node2D) -> void:
	if body == target:
		# print("target in dash range")
		target_in_dash_range = true

func _on_dash_range_body_exited(body: Node2D) -> void:
	if body == target:
		# print("target left dash range")
		target_in_dash_range = false

func end_dash() -> void:  # called when DashEndTimer reaches 0. timer is started when the dash starts.
	dash_hitbox.monitorable = false

func take_damage(damage, knockback):
	health -= damage
	#print(health)
	velocity += knockback
	stun_timer.start()
	# print("Knockback passed in: ", knockback)
	
	if health <= 0:
		queue_free()
		Global.enemy_died()

func parry_check(area: Area2D) -> void:  # calls when Hurtbox hits the player
	print(area.get_collision_layer_value(8))
	if area.get_collision_layer_value(8):
		print("parried")
		end_dash()
