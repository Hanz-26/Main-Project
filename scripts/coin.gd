extends Area2D

# Try both node names - yours uses "GameManager", Hansel's uses "Game Manager"
@onready var game_manager = get_node_or_null("%GameManager")
@onready var animation_player = get_node_or_null("AnimationPlayer")
@onready var pickup_sound = get_node_or_null("Pickup Sound")

func _ready():
	# If "GameManager" not found, try "Game Manager"
	if not game_manager:
		game_manager = get_node_or_null("%Game Manager")

func _on_body_entered(body: Node2D) -> void:
	# Play pickup sound (re-parent so it doesn't stop on queue_free)
	if pickup_sound:
		remove_child(pickup_sound)
		get_tree().current_scene.add_child(pickup_sound)
		pickup_sound.play()

	# Add score
	if game_manager:
		game_manager.add_point()

	# Play animation if it exists, otherwise just remove
	if animation_player:
		animation_player.play("pickup")
		# Wait for animation to finish before removing
		await animation_player.animation_finished
	queue_free()
