extends Area2D

func _on_area_entered(area: Area2D) -> void:
	print("Enemy hurt")
	var enemy = area.get_parent().get_parent()
	
	if enemy.has_method("enemy_take_damage"):
		enemy.enemy_take_damage()
	elif enemy.get_node("AnimatedSprite2D").sprite_frames.has_animation("death"):
		enemy.get_node("AnimatedSprite2D").play("death")
		enemy.get_node("AnimatedSprite2D/Harm Zone").monitoring = false
		enemy.get_node("AnimatedSprite2D/Harm Zone").set_deferred("monitorable", false)
		await get_tree().create_timer(10).timeout	
		if enemy:# Check the enemy was deleted during the timeout
			enemy.queue_free()
	else:
		enemy.queue_free()
