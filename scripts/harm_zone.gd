extends Area2D

var game_manager: Node = null

func _ready():
	# Try both node names
	game_manager = get_tree().current_scene.get_node_or_null("Game Manager")
	if not game_manager:
		game_manager = get_tree().current_scene.get_node_or_null("GameManager")

func _on_body_entered(body: Node2D) -> void:
	if not game_manager:
		return
	if game_manager.hearts > 0:
		game_manager.take_damage()
		if body.has_method("apply_knockback"):
			body.apply_knockback(global_position)
