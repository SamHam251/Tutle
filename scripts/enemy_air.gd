extends Enemy

# basic movement
const SPEED = Vector2(300.0, 250.0)
const ACCELERATION = Vector2(10.0, 10.0)

# enemy AI variables
var target = null
var hover_target = Vector2(0, 0)
var target_in_hover_range = false
var attacking = false
const ATTACK_WINDUP = 0.4
const ROTATION_SPEED = 12.0
var rotation_direction = 1

# hovering
@onready var max_hover_raycast: RayCast2D = $MaxHoverHeight  # hover_raycast.is_colliding()
@onready var min_hover_raycast: RayCast2D = $MinHoverHeight

# timers
@onready var action_timer: Timer = $Timers/ActionTimer
@onready var attack_timer: Timer = $Timers/AttackTimer
@onready var stun_timer: Timer = $Timers/StunTimer
const ACTION_COOLDOWN_MIN = 1.0  # time in seconds
const ACTION_COOLDOWN_MAX = 3.0  # time in seconds

# indicator and hitboxes
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_hitbox: Area2D = $AttackHitbox

func _physics_process(delta: float) -> void:
	sprite.play("default")
	#if not attack_timer.is_stopped():
		#velocity.x = move_toward(velocity.x, 0, ACCELERATION.x * 1.5)
		#velocity.y = move_toward(velocity.y, 0, ACCELERATION.y * 1.5)
	
	if attacking:
		velocity.x = move_toward(velocity.x, 0, ACCELERATION.x * 0.5)
		velocity.y = move_toward(velocity.y, 0, ACCELERATION.y * 0.5)
		
		attack_hitbox.rotate(ROTATION_SPEED * delta * rotation_direction)
		if attack_hitbox.rotation_degrees > 360 or attack_hitbox.rotation_degrees < -360:
			attacking = false
			action_timer.start(randf_range(ACTION_COOLDOWN_MIN, ACTION_COOLDOWN_MAX))
			attack_hitbox.monitorable = false
			attack_hitbox.rotation_degrees = 0
			attack_hitbox.visible = false
	elif stun_timer.is_stopped():
		hover_towards_target()

	move_and_slide()

func action() -> void:  # calls when ActionTimer reaches 0.
	if target == null or action_timer.is_stopped(): return
	action_timer.stop()  # stop new actions from happening until the current one is finished
	
	# start spin attack
	sprite.modulate = Color(3, 3, 3, 1)
	attack_timer.start(ATTACK_WINDUP)

func start_attack() -> void:  # calls when AttackTimer reaches 0.
	sprite.modulate = Color(1, 1, 1, 1)
	attacking = true
	attack_hitbox.monitoring = true
	attack_hitbox.visible = true
	
	if position.x < target.position.x:
		rotation_direction = 1  # rotate clockwise
	else:
		rotation_direction = -1  # rotate counterclockwise
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

func take_damage(damage, knockback):
	health -= damage
	print(health)
	velocity.x += knockback.x
	velocity.y += knockback.y * 0.5
	stun_timer.start()
	# print("Knockback passed in: ", knockback)
	
	if health <= 0:
		queue_free()
		Global.enemy_died()
