extends CharacterBody2D
class_name Player
var damage = 25
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@onready var ParryTimer = $"ParryTimer"
@onready var original_color = $Sprite2D.modulate
var up_or_down = 0
var slashable = true
var in_range = false
var facing = Vector2.LEFT
var saved_direction = facing
var lunge_vel = Vector2.ZERO
var facing_direction = Vector2.DOWN
var is_attacking = false

# Knockback constants and also iframes i guess
const KNOCKBACK = Vector2(-200, -150)  # sets your velocity to this when you take damage. sign of x-value depends on the hit direction.
const STUN_TIME = 0.3  # time spent being kb'd after taking damage
@onready var KnockbackTimer = $KnockbackTimer  # when active, disables player controls

func _physics_process(delta: float) -> void:
	var saved_direction: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if saved_direction != Vector2.ZERO:
		facing = saved_direction
	else:
		if is_attacking == true:
			pass
		else: 
			$AnimatedSprite2D.play("idle")
		
	lunge_vel = lunge_vel.move_toward(Vector2.ZERO, 800.0*delta)
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if KnockbackTimer.is_stopped():
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		var direction := Input.get_axis("ui_left", "ui_right")
		if direction:
			
			velocity.x = direction * SPEED
			if velocity.x > 0:
				if not is_attacking:
					$AnimatedSprite2D.flip_h = false
					$AnimatedSprite2D.play("running")
			else: 
				if not is_attacking:
					$AnimatedSprite2D.flip_h = true
					$AnimatedSprite2D.play("running")
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.x += lunge_vel.x
		if lunge_vel.y != 0:
			velocity.y = lunge_vel.y
	
	move_and_slide()
	#facing directions
<<<<<<< Updated upstream
	if Input.is_action_pressed("Slash") and slashable == true:
		if facing.x > 0:
=======
	if Input.is_action_just_pressed("Slash") and slashable == true:
		is_attacking = true
		if facing.y > 0:
			print("Slashed down")
			$AnimatedSprite2D.play("downslash")
			slashable = false
			$Pogo.monitoring = true
			$Pogo/DownslashSprite.visible = true
			$SlashTimer.start()
			await $AnimatedSprite2D.animation_finished
			is_attacking = false
		elif facing.y < 0:
			print("Slashed up")
			$AnimatedSprite2D.play("upslash")
			
			slashable = false
			$UpSlash.monitoring = true
			$"UpSlash/UpSlashSprite".visible = true
			$SlashTimer.start()
			await $AnimatedSprite2D.animation_finished
			is_attacking = false
		elif facing.x > 0:
>>>>>>> Stashed changes
			print("Slashed right")
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.play("slash")
			slashable = false
			$RightSlash.monitoring = true
<<<<<<< Updated upstream
			$RightSlash/RightSlashSprite.visible = true
			$"../SlashTimer".start()
=======
			#$RightSlash/RightSlashSprite.visible = true
			$SlashTimer.start()
			await $AnimatedSprite2D.animation_finished
			is_attacking = false
>>>>>>> Stashed changes
		elif facing.x < 0:
			print("Slashed left")
			$AnimatedSprite2D.flip_h = true
			$AnimatedSprite2D.play("slash")
			await $AnimatedSprite2D.animation_finished
			is_attacking = false
			slashable = false
			#$LeftSlash/LeftSlashSprite.visible = true
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
	print("hey")

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

<<<<<<< Updated upstream
#func slashing(enemy):
=======
func slashing(enemy):
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
		
=======

>>>>>>> Stashed changes
func slash_attack(enemy, direction: Vector2):
	if enemy is Enemy:
		enemy.take_damage(damage, direction*500)
		lunge_vel = direction*400
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
	
