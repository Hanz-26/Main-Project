extends Node

var score = 0
var hearts = 3
var lives = Global.lives
var last_safe_position = Vector2.ZERO
var initial_spawn_position = Vector2.ZERO

@onready var player: CharacterBody2D = $"../Player"

func _ready():
	hearts = 3
	lives = Global.lives
	player.get_node("UI/Health/Hearts").get_child(0).visible = true
	player.get_node("UI/Health/Hearts").get_child(2).visible = true
	player.get_node("UI/Health/Hearts").get_child(4).visible = true
	player.get_node("UI/Health/Hearts").get_child(1).visible = false
	player.get_node("UI/Health/Hearts").get_child(3).visible = false
	player.get_node("UI/Health/Hearts").get_child(5).visible = false
	player.get_node("UI/Health/Lives/Lives_count").text = ("x" + str(lives))
	# Save initial position on first run, then respawn at checkpoint or initial position
	if initial_spawn_position == Vector2.ZERO:
		initial_spawn_position = player.global_position
	if last_safe_position != Vector2.ZERO:
		player.global_position = last_safe_position
	else:
		player.global_position = initial_spawn_position

func add_point():
	score += 1
	print(score)
	player.get_node("UI/Coins/Coins_counter").text = "x" + str(score)
	if score % 10 == 0:
		lives += 1
		Global.lives = lives
		player.get_node("UI/Health/Lives/Lives_count").text = "x" + str(lives)

func take_damage(): #called by harm_zone.gd & kill_zone.gd
	hearts -= 1
	player.get_node("UI/Health/Hearts").get_child(hearts * 2).visible = false
	player.get_node("UI/Health/Hearts").get_child(hearts * 2 + 1).visible = true

	if hearts == 0:
		print("Hit by enemy")
		print("Hearts left: ", hearts)
		print("You are dead")
		player_death()
	else:
		print("Hit by enemy")
		print("Hearts left: ", hearts)

func player_death():
	if lives > 0:
		Engine.time_scale = 0.5
		Global.lives -= 1
		await get_tree().create_timer(0.5).timeout
		Engine.time_scale = 1
		print("Lives: ", Global.lives)
		_ready()
	else:
		Engine.time_scale = 0.5
		await get_tree().create_timer(0.5).timeout
		get_tree().reload_current_scene()
		print("Game Over")
		Engine.time_scale = 1
		Global.lives = 3
