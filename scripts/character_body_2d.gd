extends CharacterBody2D
class_name Player

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@onready var ParryTimer = $"ParryTimer"
@onready var original_color = $Sprite2D.modulate
var up_or_down = 0
var slashable = true
var in_range = false
var facing_direction = Vector2.DOWN

# Knockback constants and also iframes i guess
const KNOCKBACK = Vector2(-200, -150)  # sets your velocity to this when you take damage. sign of x-value depends on the hit direction.
const STUN_TIME = 0.3  # time spent being kb'd after taking damage
@onready var KnockbackTimer = $KnockbackTimer  # when active, disables player controls

func _physics_process(delta: float) -> void:
	update_facing_direction()
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if KnockbackTimer.is_stopped():
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction := Input.get_axis("ui_left", "ui_right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()
	
	if Input.is_action_just_pressed("Parry"):
		Global.parry = true
		$Sprite2D.modulate = Color(original_color.r * 10, original_color.g * 10, original_color.b * 10, original_color.a)
		ParryTimer.start()

func _on_parry_timer_timeout() -> void:
	$Sprite2D.modulate = original_color
	Global.parry = false
	Global.parried = false
	print("hey")

func _on_slash_timer_timeout() -> void:
	$RightSlash.monitoring = false
	$UpSlash.monitoring = false
	$Pogo.monitoring = false
	$LeftSlash.monitoring = false
	slashable = true

func _on_left_slash_body_entered(body: Node2D) -> void:
	Global.enemy_health -= 20

func update_facing_direction():
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	#if direction 
	#print(direction)

func hit_by_enemy(area: Area2D) -> void:
	if not KnockbackTimer.is_stopped(): return  # this is basically iframes right lol
	print("agugauguaguaguaga")
	var enemy = area.get_parent()
	if enemy == null: return  # this should never happen
	
	# (lose health here)
	velocity = Vector2(KNOCKBACK.x * -sign(enemy.velocity.x) + enemy.velocity.x * 0.2, KNOCKBACK.y)
	KnockbackTimer.start(STUN_TIME)
	
