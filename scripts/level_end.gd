extends Area2D

var _triggered := false

func _ready() -> void:
	collision_mask = 2
	body_entered.connect(_on_body_entered)

func _draw() -> void:
	# Goal pole
	draw_rect(Rect2(-3, -80, 6, 80), Color(0.55, 0.45, 0.15))
	# Gold flag
	var pts := PackedVector2Array([
		Vector2(3,  -80),
		Vector2(30, -67),
		Vector2(3,  -54),
	])
	draw_colored_polygon(pts, Color(1.0, 0.82, 0.1))
	# Star on flag
	draw_circle(Vector2(12, -67), 4, Color(1.0, 1.0, 0.4))


func _on_body_entered(body: Node2D) -> void:
	if _triggered or not body.is_in_group("player"):
		return
	_triggered = true

	# Victory jump — launch the player upward
	if body.has_method("set") and "velocity" in body:
		body.velocity = Vector2(0.0, -420.0)

	_show_win_screen(body)


func _show_win_screen(player: Node2D) -> void:
	var font := load("res://assets/fonts/PixelOperator8-Bold.ttf")

	# CanvasLayer so it draws over everything
	var canvas := CanvasLayer.new()
	canvas.layer = 10
	canvas.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child(canvas)

	# Stop any existing background music
	var music_nodes := get_tree().get_nodes_in_group("music")
	for m in music_nodes:
		if m.has_method("stop"):
			m.stop()

	# Win music
	var win_music := AudioStreamPlayer.new()
	win_music.stream = load("res://assets/music/time_for_adventure.mp3")
	win_music.volume_db = 0.0
	canvas.add_child(win_music)
	win_music.play()

	# Power-up jingle on touch
	var jingle := AudioStreamPlayer.new()
	jingle.stream = load("res://assets/sounds/power_up.wav")
	canvas.add_child(jingle)
	jingle.play()

	# Confetti — add before panel so it renders behind the panel
	var confetti_script := load("res://scripts/confetti.gd")
	var confetti := Node2D.new()
	confetti.set_script(confetti_script)
	canvas.add_child(confetti)

	# Dark overlay
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.72)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(overlay)

	# Win panel
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.set_deferred("size", Vector2(420, 220))
	panel.position = Vector2(-210, -110)
	panel.scale = Vector2.ZERO
	canvas.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 16)
	panel.add_child(vbox)

	# END header
	var end_label := Label.new()
	end_label.text = "END"
	end_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	end_label.add_theme_font_override("font", font)
	end_label.add_theme_font_size_override("font_size", 48)
	end_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
	vbox.add_child(end_label)

	# Title
	var title := Label.new()
	title.text = "Great work!"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", font)
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.1))
	vbox.add_child(title)

	# Subtitle
	var subtitle := Label.new()
	subtitle.text = "You are a LevelBreaker!"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_override("font", font)
	subtitle.add_theme_font_size_override("font_size", 22)
	subtitle.add_theme_color_override("font_color", Color(1, 1, 1))
	vbox.add_child(subtitle)

	# Wait a moment so the player can see the victory jump and confetti
	await get_tree().create_timer(0.55).timeout

	# Pop-in animation for the panel
	var tween := canvas.create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(panel, "scale", Vector2.ONE, 0.35)

	# Pause after the pop-in finishes
	await tween.finished
	get_tree().paused = true
	canvas.process_mode = Node.PROCESS_MODE_ALWAYS
