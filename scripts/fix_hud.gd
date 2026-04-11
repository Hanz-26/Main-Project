@tool
extends EditorScript

## FIX HUD - Makes hearts bigger and Q/E layout match Hansel's game
## Run: Ctrl+Shift+X

func _run():
	print("=== FIXING HUD ===")

	var player_scene = load("res://scenes/player.tscn")
	if not player_scene:
		print("ERROR: Could not load player.tscn")
		return

	var player = player_scene.instantiate()
	var ui = player.get_node_or_null("UI")

	if not ui:
		print("ERROR: No UI node found. Run setup_hud_and_sword.gd first!")
		player.queue_free()
		return

	# =============================================
	# FIX HEARTS - bigger, better positioned
	# Hansel's layout: hearts at top-left, big and clear
	# =============================================
	print("Fixing hearts...")
	var hearts = ui.get_node_or_null("Health/Hearts")
	if hearts:
		hearts.position = Vector2(12, 12)
		for child in hearts.get_children():
			if child is Sprite2D:
				child.scale = Vector2(2.0, 2.0)  # Double size
				# Recalculate spacing
				var idx = child.get_index()
				child.position = Vector2((idx / 2) * 28, 0)  # 28px apart

	# Fix lives display
	var lives = ui.get_node_or_null("Health/Lives")
	if lives:
		lives.position = Vector2(100, 8)
		var life_sprite = lives.get_node_or_null("Life_sprite")
		if life_sprite:
			life_sprite.scale = Vector2(1.2, 1.2)
		var lives_label = lives.get_node_or_null("Lives_count")
		if lives_label:
			lives_label.add_theme_font_size_override("font_size", 12)
			lives_label.position = Vector2(16, -8)

	# Fix coins display
	var coins = ui.get_node_or_null("Coins")
	if coins:
		coins.position = Vector2(12, 40)
		var coin_symbol = coins.get_node_or_null("Coin_symbol")
		if coin_symbol:
			coin_symbol.scale = Vector2(1.2, 1.2)
		var coins_label = coins.get_node_or_null("Coins_counter")
		if coins_label:
			coins_label.add_theme_font_size_override("font_size", 12)
			coins_label.position = Vector2(16, -8)

	# =============================================
	# FIX Q/E ATTACKS - bottom-left like Hansel's
	# Hansel shows: sword icon with Q below, sword icon with E below
	# =============================================
	print("Fixing Q/E attack display...")
	var attacks = ui.get_node_or_null("Attacks")
	if attacks:
		attacks.position = Vector2(12, 185)  # Bottom-left of screen

		var stab_icon = attacks.get_node_or_null("Stab")
		if stab_icon:
			stab_icon.position = Vector2(8, 0)
			stab_icon.scale = Vector2(1.2, 1.2)

		var swing_icon = attacks.get_node_or_null("Swing")
		if swing_icon:
			swing_icon.position = Vector2(35, 0)
			swing_icon.scale = Vector2(1.2, 1.2)

		var stab_letter = attacks.get_node_or_null("Stab_letter")
		if stab_letter:
			stab_letter.text = "Q"
			stab_letter.position = Vector2(2, -16)
			stab_letter.add_theme_font_size_override("font_size", 12)
			stab_letter.add_theme_color_override("font_color", Color(1, 1, 1))

		var swing_letter = attacks.get_node_or_null("Swing_letter")
		if swing_letter:
			swing_letter.text = "E"
			swing_letter.position = Vector2(30, -16)
			swing_letter.add_theme_font_size_override("font_size", 12)
			swing_letter.add_theme_color_override("font_color", Color(1, 1, 1))

	# =============================================
	# SAVE
	# =============================================
	var packed = PackedScene.new()
	packed.pack(player)
	var err = ResourceSaver.save(packed, "res://scenes/player.tscn")
	if err == OK:
		print("SUCCESS: Player scene saved with fixed HUD!")
	else:
		print("ERROR: Failed to save. Error code: ", err)

	player.queue_free()
	print("=== HUD FIX COMPLETE ===")
	print("- Hearts: 2x bigger, properly spaced")
	print("- Lives: larger font, better position")
	print("- Coins: larger font, better position")
	print("- Q/E: bottom-left with sword icons, white labels")
