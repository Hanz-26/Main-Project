@tool
extends EditorScript

## ONE SCRIPT TO FIX EVERYTHING
## Run: Ctrl+Shift+X

func _run():
	print("=== FIXING EVERYTHING ===")

	var player_scene = load("res://scenes/player.tscn")
	if not player_scene:
		print("ERROR: player.tscn not found")
		return

	var player = player_scene.instantiate()
	var heart_tex = load("res://assets/sprites/Hearts/basic/heart.png")
	var font = load("res://assets/fonts/PixelOperator8-Bold.ttf")
	if not font:
		font = load("res://assets/fonts/PixelOperator8.ttf")

	# =============================================
	# REBUILD HEARTS from scratch
	# =============================================
	var hearts_node = player.get_node_or_null("UI/Health/Hearts")
	if hearts_node:
		while hearts_node.get_child_count() > 0:
			var c = hearts_node.get_child(0)
			hearts_node.remove_child(c)
			c.free()

		hearts_node.position = Vector2(10, 10)

		if heart_tex:
			for i in range(3):
				var on = Sprite2D.new()
				on.name = "Heart_%d_On" % (i + 1)
				on.texture = heart_tex
				on.position = Vector2(i * 20, 0)
				on.scale = Vector2(1.5, 1.5)
				on.visible = true
				hearts_node.add_child(on)
				on.owner = player

				var off = Sprite2D.new()
				off.name = "Heart_%d_Off" % (i + 1)
				off.texture = heart_tex
				off.position = Vector2(i * 20, 0)
				off.scale = Vector2(1.5, 1.5)
				off.modulate = Color(0.15, 0.15, 0.15, 0.6)
				off.visible = false
				hearts_node.add_child(off)
				off.owner = player

			print("  Hearts: 3 red hearts, scale 1.5, spaced 20px")

	# =============================================
	# FIX LIVES DISPLAY
	# =============================================
	var lives_node = player.get_node_or_null("UI/Health/Lives")
	if lives_node:
		lives_node.position = Vector2(75, 5)
		var lives_label = lives_node.get_node_or_null("Lives_count")
		if lives_label:
			lives_label.position = Vector2(15, -5)
			if font:
				lives_label.add_theme_font_override("font", font)
			lives_label.add_theme_font_size_override("font_size", 10)
			lives_label.text = "x3"

	# =============================================
	# FIX COINS DISPLAY
	# =============================================
	var coins_node = player.get_node_or_null("UI/Coins")
	if coins_node:
		coins_node.position = Vector2(10, 25)
		var coins_label = coins_node.get_node_or_null("Coins_counter")
		if coins_label:
			coins_label.position = Vector2(15, -5)
			if font:
				coins_label.add_theme_font_override("font", font)
			coins_label.add_theme_font_size_override("font_size", 10)

	# =============================================
	# FIX Q/E - smaller, bottom-left
	# =============================================
	var attacks = player.get_node_or_null("UI/Attacks")
	if attacks:
		attacks.position = Vector2(10, 190)
		for child in attacks.get_children():
			if child is Label:
				if font:
					child.add_theme_font_override("font", font)
				child.add_theme_font_size_override("font_size", 8)
				child.scale = Vector2(1.5, 1.5)
			if child is Sprite2D:
				child.scale = Vector2(1.0, 1.0)

	# =============================================
	# SAVE
	# =============================================
	var packed = PackedScene.new()
	packed.pack(player)
	var err = ResourceSaver.save(packed, "res://scenes/player.tscn")
	if err == OK:
		print("SUCCESS: Player scene saved!")
	else:
		print("ERROR: ", err)

	player.queue_free()
	print("=== DONE ===")
