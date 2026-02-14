extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $".."
@onready var game_manager: Node = $"../../../../../Game Manager"

var is_active = false

func _on_body_entered(body: Node2D) -> void:
	if (not is_active):
		animated_sprite_2d.play("waving")
		is_active = true
		game_manager.player_spawn.global_position = animated_sprite_2d.get_parent().global_position
		if Global.active_spawn == null:
			Global.active_spawn = animated_sprite_2d.get_node("Area2D")
		else:
			Global.active_spawn.checkpoint_deactivate()
			Global.active_spawn = animated_sprite_2d.get_node("Area2D")
		#print("checkpoint\nGlobal active spawn is: ", Global.active_spawn, "\n")

func checkpoint_deactivate():
	self.get_parent().play("default")
	is_active = false
