extends Area2D

func _on_area_entered(area: Area2D) -> void:
	# Walk up the tree to find the enemy root (handles varying scene structures)
	var node = area.get_parent()
	for i in 4:
		if node == null or node == get_tree().current_scene:
			return
		if node.is_in_group("enemies"):
			print("Enemy killed: ", node.name)
			if node.has_method("enemy_take_damage"):
				node.enemy_take_damage()
			else:
				node.queue_free()
			return
		node = node.get_parent()
