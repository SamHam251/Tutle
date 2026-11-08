extends Node

enum EnemyType {
	Ground,
	Air
}

const enemy_ground = preload("res://scenes/enemy_ground.tscn")
const enemy_air = preload("res://scenes/enemy_air.tscn")
const main_scene = preload("res://scenes/game.tscn")
var player = null  # when the scene loads, the player will be registered to this variable

const ENEMY_SPAWN_DISTANCE = 400  # minimum distance spawned enemies must be from the player
const ENEMY_COUNT_SCALING = 15  # affects how many enemies spawn per wave based on your score. higher value -> enemy count increases slower
var parry = false
var parried = false
var player_health = 100
var score = 0
var combo = 0
var kills = 0
var killstreak = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		spawn_new_enemies()
		# score += 10000
		# kills += 100
	

func enemy_died() -> void:
	killstreak += 1
	score += 50 * killstreak
	player_health += killstreak
	
	print(get_tree().current_scene)

func check_for_enemies_left() -> bool:
	# var game = get_tree().current_scene()
	
	# for child in game.root.get_children():
		# pass
	
	return true

func landed_attack(in_air: bool = false) -> void:
	combo += 1
	if in_air:  # only if BOTH enemy and player are in the air!
		score += combo * 2
	else:
		score += combo

func landed_parry() -> void:
	score += 10 + combo + killstreak * 10

func took_damage() -> void:
	player_health -= 19
	combo = 0
	killstreak = 0
	score *= 0.8

func spawn_new_enemies() -> void:
	var enemy_count = 1 + floor(sqrt(score) / ENEMY_COUNT_SCALING)
	print(enemy_count)
	for i in range(enemy_count):
		var new_enemy = [enemy_ground, enemy_air].pick_random().instantiate()
		# var new_enemy = enemy_ground.instantiate()
		while new_enemy.position == Vector2(0, 0) or (new_enemy.position - player.position).length() < ENEMY_SPAWN_DISTANCE:
			new_enemy.position = Vector2(randf_range(0, get_window().size.x - 50), randf_range(0, get_window().size.y - 400))
		add_child(new_enemy)
		print(new_enemy)
