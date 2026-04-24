extends Area2D

func _on_area_entered(area: Area2D) -> void:
	print("Enemy killed")
	var enemy = area.get_parent().get_parent()
	if enemy.has_method("enemy_take_damage"):
		enemy.enemy_take_damage()
	else:
		enemy.queue_free()
