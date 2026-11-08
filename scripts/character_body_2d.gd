extends CharacterBody2D
class_name Player
var damage = 25
const SPEED = 300.0
const JUMP_VELOCITY = -500.0
@onready var ParryTimer = $"ParryTimer"
@onready var original_color = $AnimatedSprite2D.modulate
var up_or_down = 0
var slashable = true
var in_range = false
var facing = Vector2.LEFT
var saved_direction = facing
var lunge_vel = Vector2.ZERO
var facing_direction = Vector2.DOWN
@onready var CollisionHitbox = $CollisionHitbox
var is_attacking = false
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var Hurtbox = $Hurtbox
@onready var Slash_Miss_SFX = $"slash-miss"
@onready var Slash_SFX = [$"slash-hit-1"]
@onready var Slam_SFX = $"slash-slam"

# Knockback constants and also iframes i guess
const KNOCKBACK = Vector2(-200, -150)  # sets your velocity to this when you take damage. sign of x-value depends on the hit direction.
const STUN_TIME = 0.3  # time spent being kb'd after taking damage
@onready var KnockbackTimer = $KnockbackTimer  # when active, disables player controls

# Down slam attack
var downslam: bool = false
const DOWNSLAM_SPEED = 850.0

func _ready() -> void:
	Global.player = self

func _physics_process(delta: float) -> void:
	saved_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if saved_direction != Vector2.ZERO:
		facing = saved_direction
		
	lunge_vel = lunge_vel.move_toward(Vector2.ZERO, 800.0*delta)
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
		if downslam:
			velocity.y = DOWNSLAM_SPEED
	else:
		if downslam:
			end_downslam()

	if KnockbackTimer.is_stopped():
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		var direction := Input.get_axis("ui_left", "ui_right")
		if direction:
			velocity.x = direction * SPEED
			if velocity.x > 0:
				if not is_attacking:
					sprite.flip_h = false
					sprite.play("running")
			else:
				if not is_attacking:
					sprite.flip_h = true
					sprite.play("running")
		else:
			
			velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.x += lunge_vel.x
		if lunge_vel.y != 0:
			if is_on_floor() and lunge_vel.y > 0:
				lunge_vel.y = 0
			velocity.y = lunge_vel.y

	if velocity.x == 0 and not is_attacking:
		sprite.play("idle")
	
	move_and_slide()
	
	#facing directions
	if Input.is_action_just_pressed("Slash") and slashable == true:
		is_attacking = true
		if facing.y > 0:
			# print("Slashed down")
			sprite.play("downslash")
			slashable = false
			$Pogo.monitoring = true
			if not is_on_floor():
				start_downslam()
			$SlashTimer.start()
			Slam_SFX.play()
			await sprite.animation_finished
			is_attacking = false
			
		# elif facing.y > 0:
				# print("Slashed left")
			'''sprite.flip_h = true
			sprite.play("slash")
			slashable = false
			$LeftSlash.monitoring = true
			$SlashTimer.start()
			await sprite.animation_finished
			is_attacking = false'''
		elif facing.y < 0:
			# print("Slashed up")
			sprite.play("spinning")
			slashable = false
			$UpSlash.monitoring = true
			$SlashTimer.start()
			Slash_Miss_SFX.play()
			await sprite.animation_finished
			is_attacking = false
		elif facing.x > 0:
			sprite.flip_h = false
			sprite.play("slash")
			# print("Slashed right")
			slashable = false
			$RightSlash.monitoring = true
			$SlashTimer.start()
			Slash_Miss_SFX.play()
			await sprite.animation_finished
			is_attacking = false
		elif facing.x < 0:
			# print("Slashed left")
			sprite.flip_h = true
			sprite.play("slash")
			slashable = false
			$LeftSlash.monitoring = true
			$SlashTimer.start()
			Slash_Miss_SFX.play()
			await sprite.animation_finished
			is_attacking = false
	#parry
	if Input.is_action_just_pressed("Parry"):
		Global.parry = true
		sprite.modulate = Color(original_color.r * 10, original_color.g * 10, original_color.b * 10, original_color.a)
		set_collision_layer_value(8, true)
		Hurtbox.set_collision_layer_value(8, true)
		ParryTimer.start()
		reset_slash()

func start_downslam() -> void:
	downslam = true
	$Pogo.monitoring = true
	sprite.sprite_frames.set_animation_loop_mode("downslash", sprite.sprite_frames.LoopMode.LOOP_LINEAR)

func end_downslam() -> void:
	downslam = false
	$Pogo.monitoring = false
	sprite.sprite_frames.set_animation_loop_mode("downslash", sprite.sprite_frames.LoopMode.LOOP_NONE)
	sprite.frame = 3

func reset_parry() -> void:
	sprite.modulate = original_color
	Global.parry = false
	Global.parried = false
	set_collision_layer_value(8, false)
	Hurtbox.set_collision_layer_value(8, false)

func reset_slash() -> void:  # called when slash timer hits 0
	$RightSlash.monitoring = false
	$UpSlash.monitoring = false
	$Pogo.monitoring = false
	$LeftSlash.monitoring = false
	slashable = true
	# print("return")

func left_slash(area: Area2D) -> void:  # called when an enemy hurtbox collides with LeftSlash
	var enemy = area.get_parent()
	if enemy == null: return  # shouldnt happen
	slash_attack(enemy, Vector2.LEFT)

func pogo(area: Area2D) -> void:  # called when an enemy hurtbox collides with Pogo
	var enemy = area.get_parent()
	if area == null: return
	slash_attack(enemy, Vector2.DOWN * 2)

func up_slash(area: Area2D) -> void:  # you get the idea
	var enemy = area.get_parent()
	if enemy == null: return
	slash_attack(enemy, Vector2.UP)

func right_slash(area: Area2D) -> void:
	var enemy = area.get_parent()
	if enemy == null: return
	slash_attack(enemy, Vector2.RIGHT)

func slash_attack(enemy, direction: Vector2):
	if enemy is Enemy:
		Global.landed_attack(not (enemy.is_on_floor() and self.is_on_floor()))
		Slash_SFX.pick_random().play()
		
		# knockback modifiers (both)
		if direction.y == 0 and not (enemy.is_on_floor() or self.is_on_floor()):
			direction.y = Vector2.UP.y * 1  # nine sols air attack
		
		# knockback modifiers (enemy only)
		if direction.y < 0 and enemy.position.y < position.y - 50: direction.y *= 0.1
		
		# apply damage and kb to enemy
		enemy.take_damage(damage, Vector2(-direction.x * 400, direction.y * 400))
		
		# knockback modifiers (player only)
		if direction.y < 0 and enemy.position.y < position.y - 50: direction.y *= 10  # undoing the enemy-only modifier
		if enemy.name == "EnemyAir":
			#print("test")
			pass
		
		# apply "kb" to player
		lunge_vel = Vector2(direction.x * 300, direction.y * 425)
		if lunge_vel.y > 0: lunge_vel.y = 0

func update_facing_direction():
	pass
	# var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	#if direction 
	#print(direction)

func hit_by_enemy(area: Area2D) -> void:  # calls when the player's hurtbox collides with something from layer 7.
	if not KnockbackTimer.is_stopped(): return  # this is basically iframes right lol
	var enemy = area.get_parent()
	if enemy == null: return  # this should never happen
	
	if Global.parry:
		# print("Parried an attack")
		Global.landed_parry()
		return
	
	Global.took_damage()
	# print("agugauguaguaguaga ", Global.player_health)
	
	# (lose health here)
	velocity = Vector2(KNOCKBACK.x * -sign(enemy.velocity.x) + enemy.velocity.x * 0.2, KNOCKBACK.y)
	KnockbackTimer.start(STUN_TIME)
