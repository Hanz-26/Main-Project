extends Area2D

func _on_area_entered(area: Area2D) -> void:
	print("Enemy killed")
	area.get_parent().get_parent().queue_free()
