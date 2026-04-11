extends Area2D

@onready var timer: Timer = $Timer
var game_manager = null
var player = null

func _ready():
	game_manager = get_tree().current_scene.get_node_or_null("GameManager")
	if not game_manager:
		game_manager = get_tree().current_scene.get_node_or_null("Game Manager")
	player = get_tree().current_scene.get_node_or_null("Player")

func _on_body_entered(body: Node2D) -> void:
	if game_manager and game_manager.has_method("take_damage"):
		# Lose 1 heart (not all 3)
		game_manager.take_damage()
	else:
		# Fallback - old behavior
		print("You died!")
		Engine.time_scale = 0.5
		body.get_node("CollisionShape2D").queue_free()
		timer.start()

func _on_timer_timeout() -> void:
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
