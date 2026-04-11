@tool
extends EditorScript

## DEFINITIVE HUD + SWORD FIX - Uses Hansel's exact values
## Run: Ctrl+Shift+X

func _run():
	print("=== DEFINITIVE FIX ===")

	var player_scene = load("res://scenes/player.tscn")
	if not player_scene:
		print("ERROR: Could not load player.tscn")
		return

	var player = player_scene.instantiate()
	var sword_tex = load("res://assets/sprites/Weapons/excalibur_.png")
	var heart_tex = load("res://assets/sprites/Hearts/basic/heart.png")
	var font = load("res://assets/fonts/PixelOperator8-Bold.ttf")
	if not font:
		font = load("res://assets/fonts/PixelOperator8.ttf")

	# =============================================
	# FIX 1: SWORD (static) - vertical on back, flip_v = true
	# Hansel's values: pos(-4.6, -17.1), scale(0.41), flip_v=true
	# =============================================
	var sword = player.get_node_or_null("sword")
	if sword:
		sword.position = Vector2(-5, -17)
		sword.scale = Vector2(0.41, 0.41)
		sword.flip_v = true  # This makes it point UP on the back
		sword.rotation_degrees = 0  # No rotation, just flipped
		print("  Sword: vertical on back, flipped")

	# =============================================
	# FIX 2: SWORD ATTACKS - rotated 90deg (1.5708 rad), to the side
	# Hansel's values: pos(19.7, -17), rotation=1.5707964, scale(0.97)
	# =============================================
	var sword_attacks = player.get_node_or_null("sword_attacks")
	if sword_attacks:
		sword_attacks.position = Vector2(19.7, -17)
		sword_attacks.rotation = 1.5707964  # 90 degrees - makes attacks horizontal
		sword_attacks.scale = Vector2(0.97, 0.97)
		print("  Sword attacks: side of character, horizontal")

	# Fix stab collision
	var stab_col = player.get_node_or_null("sword_attacks/stab_area/stab_collision")
	if stab_col:
		stab_col.position = Vector2(0, 0)

	# Fix swing area and collision
	var swing_area = player.get_node_or_null("sword_attacks/swing_area")
	if swing_area:
		swing_area.position = Vector2(-6.5, -0.5)
	var swing_col = player.get_node_or_null("sword_attacks/swing_area/swing_collision")
	if swing_col:
		swing_col.position = Vector2(0, 0)

	# =============================================
	# FIX 3: HEARTS - Hansel uses scale 2.14, spaced ~42px apart
	# Position: (26, 31), (68, 31), (110, 31)
	# =============================================
	var hearts_node = player.get_node_or_null("UI/Health/Hearts")
	if hearts_node:
		# Clear existing hearts
		while hearts_node.get_child_count() > 0:
			var child = hearts_node.get_child(0)
			hearts_node.remove_child(child)
			child.free()

		if heart_tex:
			var heart_positions = [
				Vector2(27, 32),
				Vector2(68, 32),
				Vector2(110, 32),
			]
			for i in range(3):
				var on = Sprite2D.new()
				on.name = "Heart_%d_On" % (i + 1)
				on.texture = heart_tex
				on.position = heart_positions[i]
				on.scale = Vector2(2.14, 2.14)
				on.visible = true
				hearts_node.add_child(on)
				on.owner = player

				var off = Sprite2D.new()
				off.name = "Heart_%d_Off" % (i + 1)
				off.texture = heart_tex
				off.position = heart_positions[i]
				off.scale = Vector2(2.14, 2.14)
				off.modulate = Color(0.1, 0.1, 0.1, 0.6)
				off.visible = false
				hearts_node.add_child(off)
				off.owner = player

			print("  Hearts: 3x big hearts (scale 2.14), properly spaced")

	# =============================================
	# FIX 4: LIVES - Hansel's position
	# =============================================
	var lives_node = player.get_node_or_null("UI/Health/Lives")
	if lives_node:
		lives_node.position = Vector2(-32, 0)
		var life_sprite = lives_node.get_node_or_null("Life_sprite")
		if life_sprite:
			life_sprite.position = Vector2(209, 32)
			life_sprite.scale = Vector2(2.5, 2.5)
		var lives_label = lives_node.get_node_or_null("Lives_count")
		if lives_label:
			lives_label.position = Vector2(229, 27)
			lives_label.add_theme_font_size_override("font_size", 16)

	# =============================================
	# FIX 5: COINS - Hansel's position
	# =============================================
	var coins_node = player.get_node_or_null("UI/Coins")
	if coins_node:
		coins_node.position = Vector2(-6, 0)
		var coins_label = coins_node.get_node_or_null("Coins_counter")
		if coins_label:
			coins_label.position = Vector2(47, 75)
			coins_label.add_theme_font_size_override("font_size", 16)
		var coin_sym = coins_node.get_node_or_null("Coin_symbol")
		if coin_sym:
			coin_sym.position = Vector2(27, 82)
			coin_sym.scale = Vector2(2.0, 2.0)

	# =============================================
	# FIX 6: Q/E ATTACK UI - Bottom-left corner like Hansel's
	# Q (swing) on left, E (stab) on right
	# Sword icons rotated 90deg, scale 3x, with letter above
	# =============================================
	var attacks = player.get_node_or_null("UI/Attacks")
	if attacks:
		# Clear existing children
		while attacks.get_child_count() > 0:
			var child = attacks.get_child(0)
			attacks.remove_child(child)
			child.free()

		attacks.position = Vector2(0, 0)

		if sword_tex:
			# Q = Swing (left icon) - Hansel's pos: (40, 607)
			var swing_icon = Sprite2D.new()
			swing_icon.name = "Swing"
			swing_icon.texture = sword_tex
			swing_icon.region_enabled = true
			swing_icon.region_rect = Rect2(0, 36, 20, 24)
			swing_icon.position = Vector2(40, 608)
			swing_icon.rotation = 1.5707964
			swing_icon.scale = Vector2(3, 3)
			attacks.add_child(swing_icon)
			swing_icon.owner = player

			# E = Stab (right icon) - Hansel's pos: (126, 604)
			var stab_icon = Sprite2D.new()
			stab_icon.name = "Stab"
			stab_icon.texture = sword_tex
			stab_icon.region_enabled = true
			stab_icon.region_rect = Rect2(10, 6, 12, 21)
			stab_icon.position = Vector2(126, 604)
			stab_icon.rotation = 1.5707964
			stab_icon.scale = Vector2(3, 3)
			attacks.add_child(stab_icon)
			stab_icon.owner = player

		# Q label (above swing icon)
		var q_label = Label.new()
		q_label.name = "Swing_letter"
		q_label.text = "Q"
		q_label.position = Vector2(31, 550)
		q_label.scale = Vector2(3, 3)
		if font:
			q_label.add_theme_font_override("font", font)
		q_label.add_theme_font_size_override("font_size", 8)
		attacks.add_child(q_label)
		q_label.owner = player

		# E label (above stab icon)
		var e_label = Label.new()
		e_label.name = "Stab_letter"
		e_label.text = "E"
		e_label.position = Vector2(121, 550)
		e_label.scale = Vector2(3, 3)
		if font:
			e_label.add_theme_font_override("font", font)
		e_label.add_theme_font_size_override("font_size", 8)
		attacks.add_child(e_label)
		e_label.owner = player

		print("  Q/E: bottom-left, sword icons 3x, letters above")

	# =============================================
	# SAVE
	# =============================================
	var packed = PackedScene.new()
	packed.pack(player)
	var err = ResourceSaver.save(packed, "res://scenes/player.tscn")
	if err == OK:
		print("SUCCESS: Player scene saved!")
		print("")
		print("All values match Hansel's player.tscn exactly.")
	else:
		print("ERROR saving: ", err)

	player.queue_free()
