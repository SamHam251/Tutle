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
func _physics_process(delta: float) -> void:
	update_facing_direction()
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	#facing directions
	#if Input.is_action_pressed("Slash"):
		
		
	
		
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
