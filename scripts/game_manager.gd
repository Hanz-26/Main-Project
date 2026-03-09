extends Node

var score = 0
var hearts = 3
var lives = Global.lives

@onready var player: CharacterBody2D = $"../Player"
@onready var player_spawn: Marker2D = $"../Spawn_locations/Initial_spawn"# Original initial_spawn location (x,y) = (126.991, -37.986)
@onready var bosses: Node2D = $"../Enemies/Bosses"

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
	player.global_position = player_spawn.global_position# turn this off to freely mover player around
	player.get_node("Camera2D").enabled = true
	player.get_node("Boss_Camera2D").enabled = false

func add_point():
	score += 1
	#print(score)
	player.get_node("UI/Coins/Coins_counter").text = "x" + str(score)

func take_damage(): #called by harm_zone.gd
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
	var playground = get_parent().get_node("Layers/Playground")
	playground.collision_enabled = false
	Engine.time_scale = 0.5
	await get_tree().create_timer(0.5).timeout	
	if lives > 0:
		Global.lives -= 1
		print("Lives: ", Global.lives)	
		playground.collision_enabled = true
		_ready()
	else:
		get_tree().reload_current_scene()
		print("Game Over")
		Global.lives = 3
	Engine.time_scale = 1
	if bosses.get_node("necromancer_boss"):#resets miniboss fight if still present
		bosses.get_node("necromancer_boss").reset_boss()
