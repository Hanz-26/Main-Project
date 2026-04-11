@tool
extends EditorScript

## REBUILD HUD - Copies Hansel's EXACT values for everything
## Run: Ctrl+Shift+X

func _run():
	print("=== REBUILDING HUD (Hansel's exact values) ===")

	var player_scene = load("res://scenes/player.tscn")
	if not player_scene:
		print("ERROR: player.tscn not found")
		return

	var player = player_scene.instantiate()

	var heart_tex = load("res://assets/sprites/Hearts/animated/border/heart_animated_1.png")
	var knight_tex = load("res://assets/sprites/Characters/knight.png")
	if not knight_tex:
		knight_tex = load("res://assets/sprites/knight.png")
	var coin_tex = load("res://assets/sprites/coin.png")
	var sword_tex = load("res://assets/sprites/Weapons/excalibur_.png")
	var font = load("res://assets/fonts/PixelOperator8-Bold.ttf")
	if not font:
		font = load("res://assets/fonts/PixelOperator8.ttf")

	var ui = player.get_node_or_null("UI")
	if not ui:
		print("ERROR: No UI node!")
		player.queue_free()
		return

	# =============================================
	# NUKE ALL UI CHILDREN AND REBUILD FROM SCRATCH
	# =============================================
	while ui.get_child_count() > 0:
		var c = ui.get_child(0)
		ui.remove_child(c)
		c.free()

	# =============================================
	# HEALTH SECTION
	# =============================================
	var health = Node2D.new()
	health.name = "Health"
	ui.add_child(health)
	health.owner = player

	# --- HEARTS ---
	var hearts = Node2D.new()
	hearts.name = "Hearts"
	health.add_child(hearts)
	hearts.owner = player

	if heart_tex:
		# Hansel uses region_rect to crop: full heart = (0,0,17,17), empty = (68,0,17,17)
		var positions = [
			Vector2(27, 32),   # Heart 1
			Vector2(68, 32),   # Heart 2
			Vector2(110, 32),  # Heart 3
		]
		for i in range(3):
			# On (full heart)
			var on = Sprite2D.new()
			on.name = "Heart_%d_On" % (i + 1)
			on.texture = heart_tex
			on.region_enabled = true
			on.region_rect = Rect2(0, 0, 17, 17)  # First frame = full red heart
			on.position = positions[i]
			on.scale = Vector2(2.14, 2.14)
			on.visible = true
			hearts.add_child(on)
			on.owner = player

			# Off (empty heart)
			var off = Sprite2D.new()
			off.name = "Heart_%d_Off" % (i + 1)
			off.texture = heart_tex
			off.region_enabled = true
			off.region_rect = Rect2(68, 0, 17, 17)  # Last frame = empty dark heart
			off.position = positions[i]
			off.scale = Vector2(2.14, 2.14)
			off.visible = false
			hearts.add_child(off)
			off.owner = player

		print("  Hearts: 3x scale 2.14, using animated border spritesheet")
	else:
		print("  WARNING: heart_animated_1.png not found!")

	# --- LIVES ---
	var lives = Node2D.new()
	lives.name = "Lives"
	lives.position = Vector2(-32, 0)
	health.add_child(lives)
	lives.owner = player

	if knight_tex:
		var life_sprite = Sprite2D.new()
		life_sprite.name = "Life_sprite"
		life_sprite.texture = knight_tex
		life_sprite.region_enabled = true
		life_sprite.region_rect = Rect2(9, 9, 13, 19)  # Hansel's exact crop
		life_sprite.position = Vector2(209, 32)
		life_sprite.scale = Vector2(2.5, 2.5)
		lives.add_child(life_sprite)
		life_sprite.owner = player

	var lives_label = Label.new()
	lives_label.name = "Lives_count"
	lives_label.text = "x3"
	lives_label.offset_left = 229
	lives_label.offset_top = 27
	lives_label.offset_right = 271
	lives_label.offset_bottom = 51
	if font:
		lives_label.add_theme_font_override("font", font)
	lives_label.add_theme_font_size_override("font_size", 24)
	lives.add_child(lives_label)
	lives_label.owner = player
	print("  Lives: knight icon + x3 label, font size 24")

	# --- COINS ---
	var coins = Node2D.new()
	coins.name = "Coins"
	coins.position = Vector2(-6, 0)
	ui.add_child(coins)
	coins.owner = player

	var coins_label = Label.new()
	coins_label.name = "Coins_counter"
	coins_label.text = "x0"
	coins_label.offset_left = 47
	coins_label.offset_top = 75
	coins_label.offset_right = 103
	coins_label.offset_bottom = 107
	if font:
		coins_label.add_theme_font_override("font", font)
	coins_label.add_theme_font_size_override("font_size", 24)
	coins.add_child(coins_label)
	coins_label.owner = player

	if coin_tex:
		var coin_sym = Sprite2D.new()
		coin_sym.name = "Coin_symbol"
		coin_sym.texture = coin_tex
		coin_sym.region_enabled = true
		coin_sym.region_rect = Rect2(3, 3, 10, 10)  # Hansel's crop
		coin_sym.position = Vector2(30, 88)
		coin_sym.scale = Vector2(3.16, 3.16)
		coins.add_child(coin_sym)
		coin_sym.owner = player

	print("  Coins: coin icon + x0 label, font size 24")

	# --- ATTACKS (Q and E) ---
	var attacks = Node2D.new()
	attacks.name = "Attacks"
	ui.add_child(attacks)
	attacks.owner = player

	if sword_tex:
		# Q = Swing (left icon)
		var swing = Sprite2D.new()
		swing.name = "Swing"
		swing.texture = sword_tex
		swing.region_enabled = true
		swing.region_rect = Rect2(0, 36, 20, 24)
		swing.position = Vector2(40, 608)
		swing.rotation = 1.5707964
		swing.scale = Vector2(3, 3)
		attacks.add_child(swing)
		swing.owner = player

		# E = Stab (right icon)
		var stab = Sprite2D.new()
		stab.name = "Stab"
		stab.texture = sword_tex
		stab.region_enabled = true
		stab.region_rect = Rect2(10, 6, 12, 21)
		stab.position = Vector2(126, 604)
		stab.rotation = 1.5707964
		stab.scale = Vector2(3, 3)
		attacks.add_child(stab)
		stab.owner = player

	# Q label
	var q_label = Label.new()
	q_label.name = "Swing_letter"
	q_label.text = "Q"
	q_label.offset_left = 31
	q_label.offset_top = 550
	q_label.offset_right = 39
	q_label.offset_bottom = 558
	q_label.scale = Vector2(3, 3)
	if font:
		q_label.add_theme_font_override("font", font)
	q_label.add_theme_font_size_override("font_size", 8)
	attacks.add_child(q_label)
	q_label.owner = player

	# E label
	var e_label = Label.new()
	e_label.name = "Stab_letter"
	e_label.text = "E"
	e_label.offset_left = 121
	e_label.offset_top = 550
	e_label.offset_right = 129
	e_label.offset_bottom = 558
	e_label.scale = Vector2(3, 3)
	if font:
		e_label.add_theme_font_override("font", font)
	e_label.add_theme_font_size_override("font_size", 8)
	attacks.add_child(e_label)
	e_label.owner = player

	print("  Q/E: bottom-left, sword icons scale 3, letters scale 3")

	# =============================================
	# FIX SWORD ON BACK
	# =============================================
	var sword = player.get_node_or_null("sword")
	if sword:
		sword.position = Vector2(-5, -17)
		sword.scale = Vector2(0.41, 0.41)
		sword.flip_v = true
		sword.rotation = 0
		sword.region_enabled = true
		sword.region_rect = Rect2(8, 0, 16, 32)
		sword.visible = true
		sword.z_index = -1
		print("  Sword on back: visible, flipped, z_index=-1")

	# =============================================
	# SAVE
	# =============================================
	var packed = PackedScene.new()
	packed.pack(player)
	var err = ResourceSaver.save(packed, "res://scenes/player.tscn")
	if err == OK:
		print("")
		print("SUCCESS! All values match Hansel's player.tscn")
	else:
		print("ERROR saving: ", err)

	player.queue_free()
