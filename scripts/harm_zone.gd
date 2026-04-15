extends Area2D

#@onready var game_manager: Node = $"../../../../Game Manager"
@onready var game_manager: Node = get_tree().current_scene.get_node("Game Manager")

func _on_body_entered(body: Node2D) -> void:
	#If you're getting errors with these two functions check if the player is actually where it spawns
	#when moving it around for easy spawning it can mess it up
	if game_manager.hearts > 0 and body.name == "Player":# these functions crash the game if called with no hearts left
		#game_manager.take_damage()
		body.take_damage()
		body.apply_knockback(global_position)

#function below is for the firebreath from the dragon final boss
func _on_fireball_animation_finished() -> void:
	#print("fireball_done")
	self.get_node("../../").queue_free()
