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

# Knockback constants and also iframes i guess
const KNOCKBACK = Vector2(-200, -150)  # sets your velocity to this when you take damage. sign of x-value depends on the hit direction.
const STUN_TIME = 0.3  # time spent being kb'd after taking damage
@onready var KnockbackTimer = $KnockbackTimer  # when active, disables player controls

func _physics_process(delta: float) -> void:
	saved_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if saved_direction != Vector2.ZERO:
		facing = saved_direction
		
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
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.x += lunge_vel.x
		if lunge_vel.y != 0:
			velocity.y = lunge_vel.y
	
	move_and_slide()
	#facing directions
	if Input.is_action_pressed("Slash") and slashable == true:
		if facing.y > 0:
			print("Slashed down")
			slashable = false
			$Pogo.monitoring = true
			$Pogo/DownslashSprite.visible = true
			$SlashTimer.start()
		elif facing.y < 0:
			print("Slashed up")
			slashable = false
			$UpSlash.monitoring = true
			$"UpSlash/UpSlashSprite".visible = true
			$SlashTimer.start()
		elif facing.x > 0:
			print("Slashed right")
			slashable = false
			$RightSlash.monitoring = true
			$RightSlash/RightSlashSprite.visible = true
			$SlashTimer.start()
		elif facing.x < 0:
			print("Slashed left")
			slashable = false
			$LeftSlash/LeftSlashSprite.visible = true
			$LeftSlash.monitoring = true
			$SlashTimer.start()
			
	#parry
	if Input.is_action_just_pressed("Parry"):
		Global.parry = true
		$Sprite2D.modulate = Color(original_color.r * 10, original_color.g * 10, original_color.b * 10, original_color.a)
		ParryTimer.start()

func reset_parry() -> void:
	$Sprite2D.modulate = original_color
	Global.parry = false
	Global.parried = false

	#slashing function stuff for directional slashes
	print("hey")

func reset_slash() -> void:  # called when slash timer hits 0
	$RightSlash.monitoring = false
	$UpSlash.monitoring = false
	$Pogo.monitoring = false
	$LeftSlash.monitoring = false
	$RightSlash/RightSlashSprite.visible = false
	$"UpSlash/UpSlashSprite".visible = false
	$Pogo/DownslashSprite.visible = false
	$LeftSlash/LeftSlashSprite.visible = false
	slashable = true
	print("return")

func left_slash(area: Area2D) -> void:  # called when an enemy hurtbox collides with LeftSlash
	var enemy = area.get_parent()
	if enemy == null: return  # shouldnt happen
	slash_attack(enemy, Vector2.LEFT)

func pogo(area: Area2D) -> void:  # called when an enemy hurtbox collides with Pogo
	var enemy = area.get_parent()
	if area == null: return
	slash_attack(enemy, Vector2.DOWN)

func up_slash(area: Area2D) -> void:  # you get the idea
	var enemy = area.get_parent()
	if enemy == null: return
	slash_attack(enemy, Vector2.UP)

func right_slash(area: Area2D) -> void:
	var enemy = area.get_parent()
	if enemy == null: return
	slash_attack(enemy, Vector2.RIGHT)

'''func slashing(enemy):
	print("slashed")
	if enemy is Enemy:
		var diff = enemy.global_position - global_position 
		var knockback = Vector2.ZERO
		if abs(diff.x) > abs(diff.y):
			knockback.x = sign(diff.x) # Purely left (-1) or right (1)
		else:
			knockback.y = sign(diff.y) # Purely up (-1) or down (1)
		enemy.take_damage(damage, knockback*500)
		lunge_vel = knockback*500'''

func slash_attack(enemy, direction: Vector2):
	if enemy is Enemy:
		enemy.take_damage(damage, direction*500)
		lunge_vel = direction*400

#func _on_left_slash_body_entered(body: Node2D) -> void:
	#Global.enemy_health -= 20

func update_facing_direction():
	pass
	# var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	#if direction 
	#print(direction)

func hit_by_enemy(area: Area2D) -> void:  # calls when the player's hurtbox collides with something from layer 7.
	if not KnockbackTimer.is_stopped(): return  # this is basically iframes right lol
	
	if Global.parry:
		print("Parried an attack")
		return
	
	print("agugauguaguaguaga")
	var enemy = area.get_parent()
	if enemy == null: return  # this should never happen
	
	# (lose health here)
	velocity = Vector2(KNOCKBACK.x * -sign(enemy.velocity.x) + enemy.velocity.x * 0.2, KNOCKBACK.y)
	KnockbackTimer.start(STUN_TIME)
	
