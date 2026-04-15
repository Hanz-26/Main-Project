extends Node

var hearts = 3
var score = Global.save_files_slots[Global.active_save_file_index].get_value("Player", "coins")
var lives = Global.save_files_slots[Global.active_save_file_index].get_value("Player", "lives")
### Use below two lines to launch scene directly
#var score = 0
#var lives = 5
###
var can_be_hurt = true# This variable is for temporary invulnerability after getting hit

@onready var player: CharacterBody2D = $"../Player"
@onready var pause_menu = player.get_node("UI/pause_menu")
@onready var player_spawn: Marker2D = $"../Spawn_locations/Initial_spawn"# Original initial_spawn location (x,y) = (126.991, -37.986)
@onready var bosses: Node2D = $"../Enemies/Bosses"

#These variables are for handling pause menu
var selected_menu
var selected_menu_index = 0
var movement_is_blocked = false

func _ready():
	get_tree().paused = false
	hearts = 3
	player.get_node("UI/Health/Hearts").get_child(0).visible = true
	player.get_node("UI/Health/Hearts").get_child(2).visible = true
	player.get_node("UI/Health/Hearts").get_child(4).visible = true
	player.get_node("UI/Health/Hearts").get_child(1).visible = false
	player.get_node("UI/Health/Hearts").get_child(3).visible = false
	player.get_node("UI/Health/Hearts").get_child(5).visible = false
	player.get_node("UI/Health/Lives/Lives_count").text = ("x" + str(lives))
	player.get_node("UI/Coins/Coins_counter").text = "x" + str(score)
	player.global_position = player_spawn.global_position# turn this off to freely mover player around; check for errors harm_zone.gd
	player.get_node("Camera2D").enabled = true
	player.get_node("Boss_Camera2D").enabled = false

func _process(delta: float) -> void:
	var direction := Input.get_axis("move_up", "move_down")
	
	if not movement_is_blocked and pause_menu.visible == true and pause_menu.get_node("pause_selections").visible == true:
		if direction != 0:
			selected_menu_index += direction
			selected_menu_index = 0 if selected_menu_index < 0 else selected_menu_index
			selected_menu_index = 1 if selected_menu_index > 1 else selected_menu_index
			selected_menu = pause_menu.get_node("pause_selections").get_child(selected_menu_index)
			pause_menu.get_node("select_icon").global_position = selected_menu.global_position + Vector2(-25,0)
		
			movement_is_blocked = true
			await get_tree().create_timer(0.35).timeout	
			movement_is_blocked = false
	
	if Input.is_action_just_pressed("confirm"):
		if pause_menu.visible == true and pause_menu.get_node("pause_selections").visible == true:
			if pause_menu.get_node("quit_confirmation").visible == false:# pause menu
				match selected_menu.name:
					"pause_resume":
						if selected_menu.text == "Restart Level":# Game over screen
							get_tree().reload_current_scene()
						else:
							get_tree().paused = false
							pause_menu.visible = false
							pause_menu.get_node("quit_confirmation").visible = false
					"pause_quit":
						if pause_menu.get_node("pause_title").text == "Game Paused":
							pause_menu.get_node("quit_confirmation").visible = true
							selected_menu_index = 0
							selected_menu = pause_menu.get_node("pause_selections").get_child(selected_menu_index)
							pause_menu.get_node("select_icon").global_position = selected_menu.global_position + Vector2(-25,0)
						if pause_menu.get_node("pause_title").text == "Game Over":
							get_tree().paused = false
							get_tree().change_scene_to_file("res://scenes/Menus/main_menu.tscn")
			else:# quit game confirmation
				match selected_menu.name:
						"pause_resume":
							get_tree().paused = false
							pause_menu.visible = false
							pause_menu.get_node("quit_confirmation").visible = false
						"pause_quit":
							get_tree().paused = false
							get_tree().change_scene_to_file("res://scenes/Menus/main_menu.tscn")
	
	#Code below handles pause menu
	#Game Manager node -> Inspector -> Process -> Mode = Always: This allows the node run while scene is paused
	if Input.is_action_just_pressed("escape"):
		if lives >= 0 and hearts > 0:
			pause_menu.get_node("pause_title").text = "Game Paused"
			if pause_menu.visible == true:# exiting pause menu
				get_tree().paused = false
				pause_menu.visible = false
				pause_menu.get_node("quit_confirmation").visible = false
			else:# entering pause menu
				get_tree().paused = true
				pause_menu.visible = true
				selected_menu_index = 0
				selected_menu = pause_menu.get_node("pause_selections").get_child(selected_menu_index)
				pause_menu.get_node("select_icon").global_position = selected_menu.global_position + Vector2(-25,0)

func add_point():
	score += 1
	#print(score)
	if score == 10:# reset coins to 0; increment lives
		lives += 1
		score = 0
		player.get_node("UI/Health/Lives/Lives_count").text = ("x" + str(lives))
	player.get_node("UI/Coins/Coins_counter").text = "x" + str(score)

'''
func take_damage(): #called by harm_zone.gd
	if can_be_hurt:
		print("❤️ -1")
		### Comment these three lines out for invincibility
		#hearts -= 1
		#player.get_node("UI/Health/Hearts").get_child(hearts * 2).visible = false
		#player.get_node("UI/Health/Hearts").get_child(hearts * 2 + 1).visible = true
		###
	if hearts == 0:
		player_death()
	else:
		can_be_hurt = false
		player.get_node("AnimatedSprite2D").self_modulate = Color("red")
		await get_tree().create_timer(0.5).timeout	
		player.get_node("AnimatedSprite2D").self_modulate = Color(1, 1, 1, 1)
		can_be_hurt = true'''

func player_death():
	Engine.time_scale = 0.5
	await get_tree().create_timer(0.1).timeout	
	if lives > 0:
		lives -= 1
		#print("Lives: ", lives)	
		_ready()
	else:
		game_over()
	Engine.time_scale = 1
	if bosses.get_node("necromancer_boss"):#resets miniboss fight if still present
		bosses.get_node("necromancer_boss").reset_boss()
	if bosses.get_node("dragon_final_boss"):#resets dragon boss fight if still present
		bosses.get_node("dragon_final_boss").reset_boss()

func game_over():# shows game over screen
	get_tree().paused = true
	pause_menu.visible = true
	pause_menu.get_node("pause_title").text = "Game Over"
	selected_menu = pause_menu.get_node("pause_selections").get_child(selected_menu_index)
	selected_menu.text = "Restart Level"
	pause_menu.get_node("select_icon").global_position = selected_menu.global_position + Vector2(-40,0)
	#get_tree().reload_current_scene()
