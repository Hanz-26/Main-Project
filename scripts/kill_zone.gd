extends Area2D

@onready var timer: Timer = $Timer
#@onready var game_manager: Node = %"Game Manager"
#@onready var player: CharacterBody2D = $"../Player"
@onready var game_manager: Node = get_tree().current_scene.get_node("Game Manager")
@onready var player: CharacterBody2D = get_tree().current_scene.get_node("Player")

'''
#Original code from youtube tutorial
func _on_body_entered(body: Node2D) -> void:
	print("You are dead")
	Engine.time_scale = 0.5
	body.get_node("CollisionShape2D").queue_free()
	timer.start()

func _on_timer_timeout() -> void:
	Engine.time_scale = 1
	get_tree().reload_current_scene()
'''
func _on_body_entered(body: Node2D) -> void:
	player.get_node("UI/Health/Hearts").get_child(0).visible = false
	player.get_node("UI/Health/Hearts").get_child(2).visible = false
	player.get_node("UI/Health/Hearts").get_child(4).visible = false
	player.get_node("UI/Health/Hearts").get_child(1).visible = true
	player.get_node("UI/Health/Hearts").get_child(3).visible = true
	player.get_node("UI/Health/Hearts").get_child(5).visible = true
	game_manager.hearts = 0# This is necessary because otherwise you can press escape and leave the game over menu back to the game
	game_manager.player_death()
