extends Area2D

@onready var game_manager: Node = %"Game Manager"


func _on_body_entered(body: Node2D) -> void:
	self.get_node("Pickup Sound").play()
	print("+1 coin")
	game_manager.add_point()
	self.visible = false
	await get_tree().create_timer(0.2).timeout# pickup sound duration = 0.2 seconds
	self.queue_free()
