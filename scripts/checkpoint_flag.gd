extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $".."
var game_manager: Node = null

var is_active = false

func _ready():
	game_manager = get_tree().current_scene.get_node_or_null("GameManager")
	if not game_manager:
		game_manager = get_tree().current_scene.get_node_or_null("Game Manager")

func _on_body_entered(body: Node2D) -> void:
	if (not is_active) and body.name == "Player":
		print("Checkpoint flag reached")
		animated_sprite_2d.play("waving")
		is_active = true
		# Use the player's current position (on the ground) instead of the flag position
		var spawn_pos = body.global_position
		if game_manager:
			if game_manager.get("player_spawn"):
				game_manager.player_spawn.global_position = spawn_pos
			game_manager.last_safe_position = spawn_pos
			print("Checkpoint set at player position: ", spawn_pos)
		if Global.active_spawn == null:
			Global.active_spawn = animated_sprite_2d.get_node("Area2D")
		else:
			Global.active_spawn.checkpoint_deactivate()
			Global.active_spawn = animated_sprite_2d.get_node("Area2D")
		#print("checkpoint\nGlobal active spawn is: ", Global.active_spawn, "\n")

func checkpoint_deactivate():
	self.get_parent().play("default")
	is_active = false
