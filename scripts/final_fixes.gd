@tool
extends EditorScript

## FINAL FIXES - Run with Ctrl+Shift+X
## 1. Adds platforms connecting ice tiles (right) to descent shaft (left)
## 2. Fixes the boss to be visible and functional

func _run():
	print("=== FINAL FIXES ===")

	var scene = get_editor_interface().get_edited_scene_root()
	if not scene:
		print("ERROR: Open game.tscn first!")
		return

	var tilemap: TileMap = null
	for child in scene.get_children():
		if child is TileMap:
			tilemap = child
			break
	if not tilemap:
		print("ERROR: No TileMap!")
		return

	var S = 2
	var L = 0
	var GRASS = Vector2i(0, 0)
	var DIRT = Vector2i(4, 0)
	var ICE = Vector2i(8, 0)

	# =============================================
	# STEP 1: Connect ice tiles to descent shaft
	# Middle floor is at Y=15. Ice tiles end around x=148-157.
	# Descent shaft is at x=-15 to -10.
	# Player goes LEFT from ice tiles.
	# Need platforming challenges across the middle level.
	# The middle floor (Y=15) already spans the full width,
	# so we add ABOVE-floor obstacles and platforms for variety.
	# =============================================
	print("Step 1: Adding platforms and obstacles on middle level...")

	# --- Section 1: Near ice tiles (x=120-145) - ice theme platforms ---
	# Elevated ice platforms above the floor
	for x in range(130, 136):
		tilemap.set_cell(L, Vector2i(x, 12), S, ICE, 0)
	for x in range(120, 125):
		tilemap.set_cell(L, Vector2i(x, 10), S, ICE, 0)
	for x in range(138, 143):
		tilemap.set_cell(L, Vector2i(x, 11), S, ICE, 0)
	# Ice pillar
	for y in range(10, 15):
		tilemap.set_cell(L, Vector2i(145, y), S, ICE, 0)

	# --- Section 2: Middle area (x=70-115) - mixed platforms ---
	# Floating platforms with gaps (player must jump across)
	for x in range(100, 106):
		tilemap.set_cell(L, Vector2i(x, 12), S, GRASS, 0)
		tilemap.set_cell(L, Vector2i(x, 13), S, DIRT, 10)
	# Gap
	for x in range(90, 95):
		tilemap.set_cell(L, Vector2i(x, 11), S, GRASS, 0)
	# Another platform
	for x in range(80, 86):
		tilemap.set_cell(L, Vector2i(x, 13), S, GRASS, 0)
		tilemap.set_cell(L, Vector2i(x, 14), S, DIRT, 10)
	# Elevated stepping stones
	tilemap.set_cell(L, Vector2i(76, 11), S, GRASS, 0)
	tilemap.set_cell(L, Vector2i(77, 11), S, GRASS, 0)
	tilemap.set_cell(L, Vector2i(73, 12), S, GRASS, 0)
	tilemap.set_cell(L, Vector2i(74, 12), S, GRASS, 0)

	# --- Section 3: Left-middle (x=35-65) - challenge section ---
	# Hill
	for x in range(55, 62):
		tilemap.set_cell(L, Vector2i(x, 13), S, GRASS, 0)
		tilemap.set_cell(L, Vector2i(x, 14), S, DIRT, 10)
	for x in range(57, 60):
		tilemap.set_cell(L, Vector2i(x, 12), S, GRASS, 0)
		tilemap.set_cell(L, Vector2i(x, 13), S, DIRT, 10)

	# Floating platform
	for x in range(45, 50):
		tilemap.set_cell(L, Vector2i(x, 11), S, GRASS, 0)

	# Wall obstacle player has to jump over
	for y in range(11, 15):
		tilemap.set_cell(L, Vector2i(40, y), S, DIRT, 10)
		tilemap.set_cell(L, Vector2i(41, y), S, DIRT, 10)

	# Platform to get over wall
	for x in range(38, 43):
		tilemap.set_cell(L, Vector2i(x, 10), S, GRASS, 0)

	# --- Section 4: Near descent (x=0-30) - guide to shaft ---
	# Staircase leading to the descent hole
	for x in range(20, 26):
		tilemap.set_cell(L, Vector2i(x, 13), S, GRASS, 0)
		tilemap.set_cell(L, Vector2i(x, 14), S, DIRT, 10)

	for x in range(10, 16):
		tilemap.set_cell(L, Vector2i(x, 12), S, GRASS, 0)

	for x in range(0, 6):
		tilemap.set_cell(L, Vector2i(x, 13), S, GRASS, 0)
		tilemap.set_cell(L, Vector2i(x, 14), S, DIRT, 10)

	# Arrow-like platforms pointing to descent
	for x in range(-8, -3):
		tilemap.set_cell(L, Vector2i(x, 12), S, GRASS, 0)

	# =============================================
	# STEP 2: Fix the boss - make it visible
	# =============================================
	print("Step 2: Fixing boss visibility...")

	# Find existing boss node
	var boss_area = scene.get_node_or_null("BossArea")
	var existing_boss = null
	if boss_area:
		existing_boss = boss_area.get_node_or_null("Necromancer")

	if existing_boss:
		# Make sure it's visible
		existing_boss.visible = true
		existing_boss.position = Vector2(2448, 784)
		print("  Boss found and made visible at ", existing_boss.position)

		# Check if it has an AnimatedSprite2D and make sure it's playing
		var sprite = existing_boss.get_node_or_null("AnimatedSprite2D")
		if sprite:
			sprite.visible = true
			print("  Boss sprite set to visible")
	else:
		print("  No existing boss found. Creating one...")

		if not boss_area:
			boss_area = Node2D.new()
			boss_area.name = "BossArea"
			scene.add_child(boss_area)
			boss_area.owner = scene

		# Try loading the necromancer scene
		var necro_scene = load("res://scenes/Enemies/Bosses/necromancer.tscn")
		if necro_scene:
			var boss = necro_scene.instantiate()
			boss.name = "Necromancer"
			boss.position = Vector2(2448, 784)
			boss.visible = true
			boss_area.add_child(boss)
			boss.owner = scene
			print("  Necromancer instantiated!")
		else:
			# If necromancer scene doesn't work, create a simple boss sprite
			print("  necromancer.tscn failed. Creating sprite boss...")
			var boss_sprite = create_simple_boss(scene)
			boss_sprite.position = Vector2(2448, 784)
			boss_area.add_child(boss_sprite)
			boss_sprite.owner = scene

	# =============================================
	# STEP 3: Add slimes on the middle level platforms
	# =============================================
	print("Step 3: Adding enemies on middle level...")

	var slime_scene = load("res://scenes/slime.tscn")
	if slime_scene:
		var mid_slime_positions = [
			Vector2(1648, 184),  # near ice platforms
			Vector2(1360, 184),  # middle area
			Vector2(960, 200),   # on hill
			Vector2(720, 184),   # floating section
			Vector2(400, 200),   # near wall
			Vector2(160, 200),   # near descent
		]
		for i in range(mid_slime_positions.size()):
			var s = slime_scene.instantiate()
			s.name = "MidSlime%d" % (i + 1)
			s.position = mid_slime_positions[i]
			if not boss_area:
				boss_area = scene.get_node("BossArea")
			boss_area.add_child(s)
			s.owner = scene

	print("")
	print("=== FINAL FIXES COMPLETE ===")
	print("- Middle level has platforms from ice tiles to descent shaft")
	print("- Boss placed and made visible")
	print("- 6 slimes added on middle level")
	print(">>> Press Ctrl+S to save! <<<")

func create_simple_boss(scene_root) -> Node2D:
	# Fallback: create a visible boss using available sprites
	var boss = Node2D.new()
	boss.name = "SimpleBoss"

	# Try to use the skeleton sprite from the enemies folder
	var tex = load("res://assets/sprites/Enemies/skeleton_.png")
	if not tex:
		tex = load("res://assets/sprites/Enemies/skeletonHand_.png")

	if tex:
		var sprite = Sprite2D.new()
		sprite.name = "BossSprite"
		sprite.texture = tex
		sprite.scale = Vector2(3, 3)  # Make it big - it's a boss!
		boss.add_child(sprite)
		sprite.owner = scene_root

	# Add a label
	var label = Label.new()
	label.name = "BossLabel"
	label.text = "BOSS"
	label.position = Vector2(-20, -50)
	var font = load("res://assets/fonts/PixelOperator8-Bold.ttf")
	if font:
		label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", 10)
	label.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
	boss.add_child(label)
	label.owner = scene_root

	return boss
