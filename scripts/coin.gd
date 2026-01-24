extends Area2D

@onready var game_manager: Node = %"Game Manager"
@onready var pickup_sound: AudioStreamPlayer2D = $"Pickup Sound"
@onready var animation_player: AnimationPlayer = $AnimationPlayer

'''
func _on_body_entered(body: Node2D) -> void:
	pickup_sound.play()
	#await get_tree().create_timer(0.2).timeout
	print("+1 coin")
	game_manager.add_point()
	animation_player.play("pickup")
	#queue_free()
'''

func _on_body_entered(body: Node2D) -> void:
	remove_child(pickup_sound)
	get_tree().current_scene.add_child(pickup_sound)
	pickup_sound.play()
	#await get_tree().create_timer(0.2).timeout
	print("+1 coin")
	game_manager.add_point()
	#animation_player.play("pickup")
	queue_free()
