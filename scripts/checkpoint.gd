extends Area2D

var _activated := false
var _flag_color := Color(0.95, 0.95, 0.95)  # white when inactive

@onready var activate_sound: AudioStreamPlayer = $ActivateSound

func _draw() -> void:
	# Pole
	draw_rect(Rect2(-2, -52, 4, 52), Color(0.40, 0.26, 0.10))
	draw_circle(Vector2(0, -52), 3.5, Color(0.40, 0.26, 0.10))
	# Flag (right-pointing triangle)
	var pts := PackedVector2Array([
		Vector2(2,  -50),
		Vector2(22, -41),
		Vector2(2,  -32),
	])
	draw_colored_polygon(pts, _flag_color)


func _on_body_entered(body: Node2D) -> void:
	if _activated or not body.is_in_group("player"):
		return
	_activated = true
	_flag_color = Color(0.2, 0.88, 0.32)  # green
	queue_redraw()
	activate_sound.play()
	var gm := get_tree().get_first_node_in_group("game_manager")
	if gm:
		gm.set_checkpoint(global_position + Vector2(0, -20))
