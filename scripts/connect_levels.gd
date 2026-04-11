@tool
extends EditorScript

## CONNECT LEVELS - Creates a clear path through all 3 floors
## Run: Ctrl+Shift+X
##
## GAME FLOW:
## 1. Player starts on TOP floor (Y=8), goes RIGHT
## 2. At the right end, drops down to MIDDLE floor (Y=15)
## 3. On middle floor, goes LEFT through platforms and ice section
## 4. At the left end, finds a hole down to BOTTOM floor (Y=50)
## 5. On bottom floor, goes RIGHT through 3 biomes to the BOSS
##
## This creates a serpentine path: RIGHT -> DROP -> LEFT -> DROP -> RIGHT -> BOSS

func _run():
	print("=== CONNECTING LEVELS ===")

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

	var S = 2  # source
	var L = 0  # layer
	var GRASS = Vector2i(0, 0)
	var DIRT = Vector2i(4, 0)
	var WARM = Vector2i(8, 0)
	var WARM_F = Vector2i(6, 0)
	var ROCK = Vector2i(3, 0)
	var ROCK_F = Vector2i(7, 0)

	# =============================================
	# STEP 1: Create DROP from top floor to middle floor
	# At the right end (x=150-155), remove top floor tiles
	# so player falls to the middle floor
	# =============================================
	print("Step 1: Creating drop from top to middle floor...")

	# Remove some top floor tiles at right end to create a gap
	# Top floor is at Y=8, gap to middle at Y=15
	# Make a clear visual "drop zone" with arrow indicators
	for x in range(150, 155):
		tilemap.erase_cell(L, Vector2i(x, 8))  # remove top floor surface
	# Add guide walls so player knows to fall
	for y in range(8, 15):
		tilemap.set_cell(L, Vector2i(149, y), S, DIRT, 10)
		tilemap.set_cell(L, Vector2i(155, y), S, DIRT, 10)

	# =============================================
	# STEP 2: Create DROP from middle floor to bottom floor
	# At the LEFT end (x=-15 to -10), create a hole in middle floor
	# with stepping platforms going down to Y=50
	# =============================================
	print("Step 2: Creating drop from middle to bottom floor...")

	# Remove middle floor tiles at left to create drop zone
	for x in range(-15, -10):
		tilemap.erase_cell(L, Vector2i(x, 15))
		tilemap.erase_cell(L, Vector2i(x, 16))

	# Guide walls around the drop
	for y in range(15, 28):
		tilemap.set_cell(L, Vector2i(-16, y), S, DIRT, 10)
		tilemap.set_cell(L, Vector2i(-9, y), S, DIRT, 10)

	# Stepping platforms from middle (Y=15) down to bottom (Y=50)
	# Zigzag: left, right, left, right...
	var descent_platforms = [
		[Vector2i(-15, 20), Vector2i(-11, 20)],  # y=20
		[Vector2i(-9, 25), Vector2i(-5, 25)],     # y=25
		[Vector2i(-15, 30), Vector2i(-11, 30)],   # y=30
		[Vector2i(-9, 35), Vector2i(-5, 35)],     # y=35
		[Vector2i(-15, 40), Vector2i(-11, 40)],   # y=40
		[Vector2i(-9, 45), Vector2i(-5, 45)],     # y=45
	]

	for plat in descent_platforms:
		for x in range(plat[0].x, plat[1].x + 1):
			tilemap.set_cell(L, Vector2i(x, plat[0].y), S, GRASS, 0)

	# Extend left wall down for the descent shaft
	for y in range(20, 55):
		tilemap.set_cell(L, Vector2i(-20, y), S, DIRT, 10)
		tilemap.set_cell(L, Vector2i(-19, y), S, DIRT, 10)
	# Right wall of descent shaft
	for y in range(28, 50):
		tilemap.set_cell(L, Vector2i(-4, y), S, DIRT, 10)

	# Landing platform at bottom
	for x in range(-18, -3):
		tilemap.set_cell(L, Vector2i(x, 50), S, GRASS, 0)
		tilemap.set_cell(L, Vector2i(x, 51), S, DIRT, 10)

	# =============================================
	# STEP 3: Clean up the bottom floor path
	# Remove random scattered tiles, ensure a clear LEFT-TO-RIGHT path
	# The bottom floor terrain from rebuild_level.gd should be kept
	# but we need to make sure it connects to the landing platform
	# =============================================
	print("Step 3: Connecting landing to bottom floor...")

	# Bridge from landing (x=-3) to the green biome start (x=-20 area)
	# The green biome terrain starts around x=-20 at Y=50
	# So the landing at x=-18 to -3 at Y=50 already connects!

	# Make sure the connection from x=-3 to the biome terrain is solid
	for x in range(-3, 5):
		# Check if tile exists, if not fill it
		if tilemap.get_cell_source_id(L, Vector2i(x, 50)) == -1:
			tilemap.set_cell(L, Vector2i(x, 50), S, GRASS, 0)
			tilemap.set_cell(L, Vector2i(x, 51), S, DIRT, 10)

	# =============================================
	# STEP 4: Remove old descent platforms (from rebuild_level.gd)
	# that created confusing random paths in the middle area
	# =============================================
	print("Step 4: Cleaning up confusing mid-area platforms...")

	# Remove the old zigzag descent platforms in the middle section
	# These were at various Y=30-46 positions around x=22-31, 76-86, 126-136
	for plat_range in [
		# Left old descent
		[22, 31, 30, 47],
		# Middle old descent
		[76, 86, 30, 47],
		# Right old descent
		[126, 136, 30, 47],
	]:
		for x in range(plat_range[0], plat_range[1] + 1):
			for y in range(plat_range[2], plat_range[3] + 1):
				var src = tilemap.get_cell_source_id(L, Vector2i(x, y))
				var atlas = tilemap.get_cell_atlas_coords(L, Vector2i(x, y))
				# Only remove tiles that are single platform tiles (not part of terrain)
				if src != -1 and y < 48:
					# Don't remove if it's part of the cave floor (Y=27)
					if y != 27:
						tilemap.erase_cell(L, Vector2i(x, y))

	# =============================================
	# STEP 5: Remove old gaps in cave floor (Y=27)
	# The only way down should be through the left descent shaft
	# Fill back the cave floor so the middle level is solid
	# =============================================
	print("Step 5: Sealing cave floor (only descent at left)...")

	for x in range(28, 33):
		if tilemap.get_cell_source_id(L, Vector2i(x, 27)) == -1:
			tilemap.set_cell(L, Vector2i(x, 27), S, DIRT, 10)
	for x in range(78, 83):
		if tilemap.get_cell_source_id(L, Vector2i(x, 27)) == -1:
			tilemap.set_cell(L, Vector2i(x, 27), S, DIRT, 10)
	for x in range(128, 133):
		if tilemap.get_cell_source_id(L, Vector2i(x, 27)) == -1:
			tilemap.set_cell(L, Vector2i(x, 27), S, DIRT, 10)

	# =============================================
	# STEP 6: BOSS ARENA at the end of the bottom floor (far right)
	# Walled area where player fights the boss
	# =============================================
	print("Step 6: Building boss arena...")

	# Boss arena: x=148-157, Y=45-50
	# Floor is already there from the rocky biome
	# Add walls to enclose it
	for y in range(44, 50):
		tilemap.set_cell(L, Vector2i(147, y), S, ROCK_F, 0)  # left wall
	# Ceiling
	for x in range(147, 157):
		tilemap.set_cell(L, Vector2i(x, 44), S, ROCK_F, 0)
	# Make the floor flat in the arena
	for x in range(148, 157):
		if tilemap.get_cell_source_id(L, Vector2i(x, 50)) == -1:
			tilemap.set_cell(L, Vector2i(x, 50), S, ROCK, 0)

	# =============================================
	# STEP 7: ADD BOSSES
	# =============================================
	print("Step 7: Adding boss...")

	# Remove old sections if they exist
	for name in ["CaveSection", "ThirdFloor", "BossArea"]:
		var old = scene.get_node_or_null(name)
		if old:
			old.free()

	var boss_area = Node2D.new()
	boss_area.name = "BossArea"
	scene.add_child(boss_area)
	boss_area.owner = scene

	# Try to add necromancer boss
	var necro_scene = load("res://scenes/Enemies/Bosses/necromancer.tscn")
	if necro_scene:
		var boss = necro_scene.instantiate()
		boss.name = "Necromancer"
		boss.position = Vector2(2448, 784)  # Inside boss arena (x=153 * 16, y=49 * 16)
		boss_area.add_child(boss)
		boss.owner = scene
		print("  Necromancer boss placed!")
	else:
		print("  WARNING: necromancer.tscn not found")

	# =============================================
	# STEP 8: ADD COINS along the path
	# Follow the game flow path
	# =============================================
	print("Step 8: Adding coins along the path...")

	var coin_scene = load("res://scenes/coin.tscn")
	if coin_scene:
		var coin_positions = [
			# Top floor (player already has coins here)
			# Drop zone - coin to guide player down
			Vector2(2432, 120),  # at the drop (x=152, y=7.5)

			# Middle floor - going LEFT
			Vector2(2320, 232),  # near ice tiles
			Vector2(2000, 232),
			Vector2(1600, 232),
			Vector2(1200, 232),
			Vector2(800, 232),
			Vector2(400, 232),
			Vector2(100, 232),

			# Descent shaft - coins guide player down
			Vector2(-192, 312),  # y=20
			Vector2(-104, 392),  # y=25
			Vector2(-192, 472),  # y=30
			Vector2(-104, 552),  # y=35
			Vector2(-192, 632),  # y=40
			Vector2(-104, 712),  # y=45

			# Bottom floor - going RIGHT through biomes
			Vector2(64, 784),
			Vector2(256, 760),
			Vector2(448, 784),
			Vector2(700, 760),   # warm biome
			Vector2(960, 752),
			Vector2(1200, 784),
			Vector2(1500, 760),  # rocky biome
			Vector2(1800, 784),
			Vector2(2100, 752),
			Vector2(2350, 784),  # near boss
		]

		for i in range(coin_positions.size()):
			var c = coin_scene.instantiate()
			c.name = "PathCoin%d" % (i + 1)
			c.position = coin_positions[i]
			boss_area.add_child(c)
			c.owner = scene

	# =============================================
	# STEP 9: ADD SLIMES along the bottom floor
	# =============================================
	print("Step 9: Adding enemies...")

	var slime_scene = load("res://scenes/slime.tscn")
	if slime_scene:
		var slime_positions = [
			# Bottom floor enemies
			Vector2(160, 792),
			Vector2(400, 792),
			Vector2(650, 784),
			Vector2(900, 784),
			Vector2(1100, 792),
			Vector2(1400, 784),
			Vector2(1700, 792),
			Vector2(2000, 784),
			Vector2(2200, 792),
		]

		for i in range(slime_positions.size()):
			var s = slime_scene.instantiate()
			s.name = "PathSlime%d" % (i + 1)
			s.position = slime_positions[i]
			boss_area.add_child(s)
			s.owner = scene

	# =============================================
	# STEP 10: ADD LABELS to guide the player
	# =============================================
	print("Step 10: Adding guide labels...")

	var font = load("res://assets/fonts/PixelOperator8-Bold.ttf")

	var labels_data = [
		[Vector2(2400, 96), "Jump down!"],
		[Vector2(-200, 240), "Go down!"],
		[Vector2(2380, 776), "BOSS -->"],
	]

	for data in labels_data:
		var label = Label.new()
		label.name = "Guide_%d" % randi()
		label.position = data[0]
		label.text = data[1]
		if font:
			label.add_theme_font_override("font", font)
		label.add_theme_font_size_override("font_size", 8)
		label.add_theme_color_override("font_color", Color(1, 1, 0.3))
		boss_area.add_child(label)
		label.owner = scene

	print("")
	print("=== LEVEL PATH CONNECTED ===")
	print("Flow: TOP (right) -> DROP -> MIDDLE (left) -> DROP -> BOTTOM (right) -> BOSS")
	print("")
	print(">>> SAVE WITH Ctrl+S <<<")
	print(">>> Then run setup_hud_and_sword.gd for hearts/attacks <<<")
