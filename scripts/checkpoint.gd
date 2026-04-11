extends Area2D

## Checkpoint - when player touches this, their respawn point is updated

var activated = false

func _ready():
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		return

	# Update the game manager's respawn position
	var game_manager = get_tree().current_scene.get_node_or_null("GameManager")
	if not game_manager:
		game_manager = get_tree().current_scene.get_node_or_null("Game Manager")

	if game_manager:
		game_manager.last_safe_position = global_position
		if not activated:
			activated = true
			print("Checkpoint activated: ", name, " at ", global_position)
