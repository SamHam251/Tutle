extends CharacterBody2D
class_name Player
var damage = 25
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@onready var ParryTimer = $"../ParryTimer"
@onready var original_color = $Sprite2D.modulate
var up_or_down = 0
var slashable = true
var in_range = false
var facing = Vector2.LEFT
var saved_direction = facing
var lunge_vel = Vector2.ZERO

func _physics_process(delta: float) -> void:
	var saved_direction: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if saved_direction != Vector2.ZERO:
		facing = saved_direction
		
	lunge_vel = lunge_vel.move_toward(Vector2.ZERO, 800.0*delta)
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	velocity.x += lunge_vel.x
	if lunge_vel.y != 0:
		velocity.y = lunge_vel.y
	move_and_slide()
	#facing directions
	if Input.is_action_pressed("Slash") and slashable == true:
		if facing.x > 0:
			print("Slashed right")
			slashable = false
			$RightSlash.monitoring = true
			$RightSlash/RightSlashSprite.visible = true
			$"../SlashTimer".start()
		elif facing.x < 0:
			print("Slashed left")
			slashable = false
			$LeftSlash/LeftSlashSprite.visible = true
			$LeftSlash.monitoring = true
			$"../SlashTimer".start()
		elif facing.y > 0:
			print("Slashed down")
			slashable = false
			$Pogo.monitoring = true
			$Pogo/DownslashSprite.visible = true
			$"../SlashTimer".start()
		elif facing.y < 0:
			print("Slashed up")
			slashable = false
			$UpSlash.monitoring = true
			$"UpSlash/Upslash Sprite".visible = true
			$"../SlashTimer".start()
			
	#parry
	if Input.is_action_just_pressed("Parry"):
		Global.parry = true
		$Sprite2D.modulate = Color(original_color.r * 10, original_color.g * 10, original_color.b * 10, original_color.a)
		ParryTimer.start()
		

func _on_parry_timer_timeout() -> void:
	$Sprite2D.modulate = original_color
	Global.parry = false
	Global.parried = false

#slashing function stuff for directional slashes
func _on_slash_timer_timeout() -> void:
	$RightSlash.monitoring = false
	$UpSlash.monitoring = false
	$Pogo.monitoring = false
	$LeftSlash.monitoring = false
	$RightSlash/RightSlashSprite.visible = false
	$"UpSlash/Upslash Sprite".visible = false
	$Pogo/DownslashSprite.visible = false
	$LeftSlash/LeftSlashSprite.visible = false
	slashable = true
	
func _on_left_slash_area_entered(area: Area2D) -> void:
	var enemy = area.get_parent()
	slash_attack(enemy, Vector2.LEFT)

func _on_pogo_area_entered(area: Area2D) -> void:
	var enemy = area.get_parent()
	slash_attack(enemy, Vector2.DOWN)

func _on_up_slash_area_entered(area: Area2D) -> void:
	var enemy = area.get_parent()
	slash_attack(enemy, Vector2.UP)

func _on_right_slash_area_entered(area: Area2D) -> void:
	var enemy = area.get_parent()
	slash_attack(enemy, Vector2.RIGHT)

#func slashing(enemy):
	print("slashed")
	if enemy is Enemy:
		var diff = enemy.global_position - global_position 
		var knockback = Vector2.ZERO
		if abs(diff.x) > abs(diff.y):
			knockback.x = sign(diff.x) # Purely left (-1) or right (1)
		else:
			knockback.y = sign(diff.y) # Purely up (-1) or down (1)
		enemy.take_damage(damage, knockback*500)
		lunge_vel = knockback*500
		
func slash_attack(enemy, direction: Vector2):
	if enemy is Enemy:
		enemy.take_damage(damage, direction*500)
		lunge_vel = direction*400
