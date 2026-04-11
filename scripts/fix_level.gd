@tool
extends EditorScript

## FIX LEVEL - Run this in Godot: File > Run (Ctrl+Shift+X)
## 1. Removes bad tiles from the right side of middle layer
## 2. Rebuilds the bottom floor with proper spacing and challenges
## 3. Adds more obstacles and platforming to the cave section

func _run():
	print("=== LEVEL FIX STARTING ===")

	var scene = get_editor_interface().get_edited_scene_root()
	if not scene:
		print("ERROR: No scene open. Open game.tscn first!")
		return

	var tilemap: TileMap = null
	for child in scene.get_children():
		if child is TileMap:
			tilemap = child
			break

	if not tilemap:
		print("ERROR: No TileMap found!")
		return

	var SOURCE = 2
	var layer = 0

	# Your existing tiles
	var GREEN_GRASS = Vector2i(0, 0)
	var GREEN_DIRT = Vector2i(4, 0)
	var GREEN_ALT = 0
	var DIRT_ALT = 10
	var WARM_SURFACE = Vector2i(8, 0)
	var WARM_FILL = Vector2i(6, 0)
	var ROCKY_SURFACE = Vector2i(3, 0)
	var ROCKY_FILL = Vector2i(7, 0)

	# =============================================
	# STEP 1: REMOVE ALL BAD TILES I ADDED
	# Remove everything from Y=29 to Y=35 (the broken third floor)
	# Keep Y=27-28 (existing cave floor)
	# =============================================
	print("Step 1: Removing bad tiles...")
	var removed = 0
	for y in range(29, 40):
		for x in range(-25, 165):
			var cell = tilemap.get_cell_source_id(layer, Vector2i(x, y))
			if cell != -1:  # tile exists
				tilemap.erase_cell(layer, Vector2i(x, y))
				removed += 1
	print("Removed ", removed, " tiles")

	# Also remove bad cave platforms I added (Y=19-24 area)
	# Only remove tiles that weren't in the original level
	# The original has scattered tiles here, so be careful
	# Remove only my added platforms at specific x ranges
	for y in range(19, 25):
		for x in range(75, 147):
			# Check if this might be my added tile (green grass/dirt at these coords)
			var atlas = tilemap.get_cell_atlas_coords(layer, Vector2i(x, y))
			var src = tilemap.get_cell_source_id(layer, Vector2i(x, y))
			if src == SOURCE and (atlas == GREEN_GRASS or atlas == GREEN_DIRT):
				# Only erase if it's in my platform x-ranges
				if (x >= 75 and x <= 80) or (x >= 86 and x <= 92) or \
				   (x >= 97 and x <= 102) or (x >= 107 and x <= 113) or \
				   (x >= 118 and x <= 124) or (x >= 130 and x <= 136) or \
				   (x >= 140 and x <= 146):
					tilemap.erase_cell(layer, Vector2i(x, y))

	# =============================================
	# STEP 2: REMOVE BAD NODES (CaveSection, ThirdFloor)
	# =============================================
	print("Step 2: Removing added nodes...")
	for child_name in ["CaveSection", "ThirdFloor"]:
		var node = scene.get_node_or_null(child_name)
		if node:
			node.queue_free()
			print("  Removed: ", child_name)

	# =============================================
	# STEP 3: REBUILD CAVE PLATFORMS (better design)
	# More variety, not just flat platforms
	# =============================================
	print("Step 3: Building better cave platforms...")

	# Staircase down from left (x=72-78, Y=18-20)
	for x in range(72, 76):
		tilemap.set_cell(layer, Vector2i(x, 18), SOURCE, GREEN_GRASS, GREEN_ALT)
		tilemap.set_cell(layer, Vector2i(x, 19), SOURCE, GREEN_DIRT, DIRT_ALT)
	for x in range(76, 80):
		tilemap.set_cell(layer, Vector2i(x, 20), SOURCE, GREEN_GRASS, GREEN_ALT)
		tilemap.set_cell(layer, Vector2i(x, 21), SOURCE, GREEN_DIRT, DIRT_ALT)

	# Small floating platform (x=84-87, Y=19) - jump challenge
	for x in range(84, 88):
		tilemap.set_cell(layer, Vector2i(x, 19), SOURCE, GREEN_GRASS, GREEN_ALT)

	# L-shaped platform (x=93-98, Y=21-22)
	for x in range(93, 99):
		tilemap.set_cell(layer, Vector2i(x, 21), SOURCE, GREEN_GRASS, GREEN_ALT)
		tilemap.set_cell(layer, Vector2i(x, 22), SOURCE, GREEN_DIRT, DIRT_ALT)
	# Tall pillar on right side
	for y in range(19, 22):
		tilemap.set_cell(layer, Vector2i(98, y), SOURCE, GREEN_DIRT, DIRT_ALT)
		tilemap.set_cell(layer, Vector2i(97, y), SOURCE, GREEN_DIRT, DIRT_ALT)

	# Zigzag platforms (x=104-108 high, x=112-116 low, x=120-124 high)
	for x in range(104, 109):
		tilemap.set_cell(layer, Vector2i(x, 19), SOURCE, GREEN_GRASS, GREEN_ALT)
	for x in range(112, 117):
		tilemap.set_cell(layer, Vector2i(x, 22), SOURCE, GREEN_GRASS, GREEN_ALT)
		tilemap.set_cell(layer, Vector2i(x, 23), SOURCE, GREEN_DIRT, DIRT_ALT)
	for x in range(121, 126):
		tilemap.set_cell(layer, Vector2i(x, 20), SOURCE, GREEN_GRASS, GREEN_ALT)

	# Staircase up to right wall (x=132-140, Y=21-18)
	for x in range(132, 136):
		tilemap.set_cell(layer, Vector2i(x, 22), SOURCE, GREEN_GRASS, GREEN_ALT)
		tilemap.set_cell(layer, Vector2i(x, 23), SOURCE, GREEN_DIRT, DIRT_ALT)
	for x in range(136, 140):
		tilemap.set_cell(layer, Vector2i(x, 20), SOURCE, GREEN_GRASS, GREEN_ALT)
		tilemap.set_cell(layer, Vector2i(x, 21), SOURCE, GREEN_DIRT, DIRT_ALT)

	# =============================================
	# STEP 4: GAPS IN CAVE FLOOR for dropping down
	# =============================================
	print("Step 4: Creating gaps in cave floor...")
	for x in range(28, 33):
		tilemap.erase_cell(layer, Vector2i(x, 27))
	for x in range(78, 83):
		tilemap.erase_cell(layer, Vector2i(x, 27))
	for x in range(128, 133):
		tilemap.erase_cell(layer, Vector2i(x, 27))

	# =============================================
	# STEP 5: BUILD THIRD FLOOR (much lower, same gap as top-to-middle)
	# Top floor = Y=8, Middle floor = Y=15 (gap of 7)
	# Middle floor = Y=15, Cave floor = Y=27 (gap of 12)
	# Third floor at Y=42 (gap of 15 from cave floor = more room)
	# =============================================
	print("Step 5: Building third floor at Y=42 (proper spacing)...")

	# Third floor ground: Y=42-44
	# GREEN biome: x=-20 to 40
	for x in range(-20, 41):
		tilemap.set_cell(layer, Vector2i(x, 42), SOURCE, GREEN_GRASS, GREEN_ALT)
		tilemap.set_cell(layer, Vector2i(x, 43), SOURCE, GREEN_DIRT, DIRT_ALT)
		tilemap.set_cell(layer, Vector2i(x, 44), SOURCE, GREEN_DIRT, DIRT_ALT)

	# GAP between green and warm biome (x=41-44) - pit with killzone
	# (leave empty)

	# WARM biome: x=45 to 100
	for x in range(45, 101):
		tilemap.set_cell(layer, Vector2i(x, 42), SOURCE, WARM_SURFACE, 0)
		tilemap.set_cell(layer, Vector2i(x, 43), SOURCE, WARM_FILL, 0)
		tilemap.set_cell(layer, Vector2i(x, 44), SOURCE, WARM_FILL, 0)

	# GAP (x=101-104)

	# ROCKY biome: x=105 to 157
	for x in range(105, 158):
		tilemap.set_cell(layer, Vector2i(x, 42), SOURCE, ROCKY_SURFACE, 0)
		tilemap.set_cell(layer, Vector2i(x, 43), SOURCE, ROCKY_FILL, 0)
		tilemap.set_cell(layer, Vector2i(x, 44), SOURCE, ROCKY_FILL, 0)

	# Side walls for third floor area
	for y in range(28, 45):
		tilemap.set_cell(layer, Vector2i(-20, y), SOURCE, GREEN_DIRT, DIRT_ALT)
		tilemap.set_cell(layer, Vector2i(-19, y), SOURCE, GREEN_DIRT, DIRT_ALT)
		tilemap.set_cell(layer, Vector2i(157, y), SOURCE, ROCKY_FILL, 0)
		tilemap.set_cell(layer, Vector2i(156, y), SOURCE, ROCKY_FILL, 0)

	# =============================================
	# STEP 6: STEPPING PLATFORMS from cave floor to third floor
	# Need to traverse Y=27 down to Y=42 (15 tiles gap)
	# =============================================
	print("Step 6: Adding descent platforms...")

	# Left descent (green biome)
	for x in range(25, 30):
		tilemap.set_cell(layer, Vector2i(x, 30), SOURCE, GREEN_GRASS, GREEN_ALT)
		tilemap.set_cell(layer, Vector2i(x, 31), SOURCE, GREEN_DIRT, DIRT_ALT)
	for x in range(18, 23):
		tilemap.set_cell(layer, Vector2i(x, 33), SOURCE, GREEN_GRASS, GREEN_ALT)
	for x in range(26, 31):
		tilemap.set_cell(layer, Vector2i(x, 36), SOURCE, GREEN_GRASS, GREEN_ALT)
		tilemap.set_cell(layer, Vector2i(x, 37), SOURCE, GREEN_DIRT, DIRT_ALT)
	for x in range(18, 23):
		tilemap.set_cell(layer, Vector2i(x, 39), SOURCE, GREEN_GRASS, GREEN_ALT)

	# Middle descent (warm biome)
	for x in range(76, 81):
		tilemap.set_cell(layer, Vector2i(x, 30), SOURCE, WARM_SURFACE, 0)
		tilemap.set_cell(layer, Vector2i(x, 31), SOURCE, WARM_FILL, 0)
	for x in range(83, 88):
		tilemap.set_cell(layer, Vector2i(x, 33), SOURCE, WARM_SURFACE, 0)
	for x in range(76, 81):
		tilemap.set_cell(layer, Vector2i(x, 36), SOURCE, WARM_SURFACE, 0)
		tilemap.set_cell(layer, Vector2i(x, 37), SOURCE, WARM_FILL, 0)
	for x in range(83, 88):
		tilemap.set_cell(layer, Vector2i(x, 39), SOURCE, WARM_SURFACE, 0)

	# Right descent (rocky biome)
	for x in range(126, 131):
		tilemap.set_cell(layer, Vector2i(x, 30), SOURCE, ROCKY_SURFACE, 0)
		tilemap.set_cell(layer, Vector2i(x, 31), SOURCE, ROCKY_FILL, 0)
	for x in range(133, 138):
		tilemap.set_cell(layer, Vector2i(x, 33), SOURCE, ROCKY_SURFACE, 0)
	for x in range(126, 131):
		tilemap.set_cell(layer, Vector2i(x, 36), SOURCE, ROCKY_SURFACE, 0)
		tilemap.set_cell(layer, Vector2i(x, 37), SOURCE, ROCKY_FILL, 0)
	for x in range(133, 138):
		tilemap.set_cell(layer, Vector2i(x, 39), SOURCE, ROCKY_SURFACE, 0)

	# =============================================
	# STEP 7: OBSTACLES ON THIRD FLOOR
	# Hills, walls, pits, platforms for challenge
	# =============================================
	print("Step 7: Adding obstacles and challenges on third floor...")

	# --- GREEN BIOME OBSTACLES ---
	# Hill 1
	for x in range(0, 5):
		tilemap.set_cell(layer, Vector2i(x, 41), SOURCE, GREEN_GRASS, GREEN_ALT)
		tilemap.set_cell(layer, Vector2i(x, 42), SOURCE, GREEN_DIRT, DIRT_ALT)
	for x in range(1, 4):
		tilemap.set_cell(layer, Vector2i(x, 40), SOURCE, GREEN_GRASS, GREEN_ALT)
		tilemap.set_cell(layer, Vector2i(x, 41), SOURCE, GREEN_DIRT, DIRT_ALT)

	# Pit in green section (x=12-15 - remove floor)
	for x in range(12, 16):
		tilemap.erase_cell(layer, Vector2i(x, 42))

	# Elevated platform above pit
	for x in range(11, 17):
		tilemap.set_cell(layer, Vector2i(x, 39), SOURCE, GREEN_GRASS, GREEN_ALT)

	# Wall obstacle
	for y in range(39, 42):
		tilemap.set_cell(layer, Vector2i(25, y), SOURCE, GREEN_DIRT, DIRT_ALT)
		tilemap.set_cell(layer, Vector2i(26, y), SOURCE, GREEN_DIRT, DIRT_ALT)

	# Staircase
	tilemap.set_cell(layer, Vector2i(30, 41), SOURCE, GREEN_GRASS, GREEN_ALT)
	tilemap.set_cell(layer, Vector2i(31, 41), SOURCE, GREEN_GRASS, GREEN_ALT)
	tilemap.set_cell(layer, Vector2i(32, 40), SOURCE, GREEN_GRASS, GREEN_ALT)
	tilemap.set_cell(layer, Vector2i(33, 40), SOURCE, GREEN_GRASS, GREEN_ALT)
	tilemap.set_cell(layer, Vector2i(34, 39), SOURCE, GREEN_GRASS, GREEN_ALT)
	tilemap.set_cell(layer, Vector2i(35, 39), SOURCE, GREEN_GRASS, GREEN_ALT)

	# --- WARM BIOME OBSTACLES ---
	# Pit (x=55-59)
	for x in range(55, 60):
		tilemap.erase_cell(layer, Vector2i(x, 42))

	# Floating platforms over pit
	for x in range(54, 57):
		tilemap.set_cell(layer, Vector2i(x, 39), SOURCE, WARM_SURFACE, 0)
	for x in range(58, 61):
		tilemap.set_cell(layer, Vector2i(x, 38), SOURCE, WARM_SURFACE, 0)

	# Hill cluster
	for x in range(65, 72):
		tilemap.set_cell(layer, Vector2i(x, 41), SOURCE, WARM_SURFACE, 0)
		tilemap.set_cell(layer, Vector2i(x, 42), SOURCE, WARM_FILL, 0)
	for x in range(67, 70):
		tilemap.set_cell(layer, Vector2i(x, 40), SOURCE, WARM_SURFACE, 0)
		tilemap.set_cell(layer, Vector2i(x, 41), SOURCE, WARM_FILL, 0)

	# Another pit (x=80-84)
	for x in range(80, 85):
		tilemap.erase_cell(layer, Vector2i(x, 42))

	# Stepping stones over pit
	tilemap.set_cell(layer, Vector2i(81, 40), SOURCE, WARM_SURFACE, 0)
	tilemap.set_cell(layer, Vector2i(83, 39), SOURCE, WARM_SURFACE, 0)

	# Wall
	for y in range(39, 42):
		tilemap.set_cell(layer, Vector2i(92, y), SOURCE, WARM_FILL, 0)
		tilemap.set_cell(layer, Vector2i(93, y), SOURCE, WARM_FILL, 0)

	# --- ROCKY BIOME OBSTACLES ---
	# Tall pillar
	for y in range(37, 42):
		tilemap.set_cell(layer, Vector2i(115, y), SOURCE, ROCKY_FILL, 0)
		tilemap.set_cell(layer, Vector2i(116, y), SOURCE, ROCKY_FILL, 0)

	# Pit (x=120-125)
	for x in range(120, 126):
		tilemap.erase_cell(layer, Vector2i(x, 42))

	# Platforms over rocky pit
	for x in range(119, 122):
		tilemap.set_cell(layer, Vector2i(x, 39), SOURCE, ROCKY_SURFACE, 0)
	for x in range(123, 126):
		tilemap.set_cell(layer, Vector2i(x, 38), SOURCE, ROCKY_SURFACE, 0)

	# Staircase up
	tilemap.set_cell(layer, Vector2i(130, 41), SOURCE, ROCKY_SURFACE, 0)
	tilemap.set_cell(layer, Vector2i(131, 41), SOURCE, ROCKY_SURFACE, 0)
	tilemap.set_cell(layer, Vector2i(132, 40), SOURCE, ROCKY_SURFACE, 0)
	tilemap.set_cell(layer, Vector2i(133, 40), SOURCE, ROCKY_SURFACE, 0)
	tilemap.set_cell(layer, Vector2i(134, 39), SOURCE, ROCKY_SURFACE, 0)
	tilemap.set_cell(layer, Vector2i(135, 39), SOURCE, ROCKY_SURFACE, 0)

	# Hill at end
	for x in range(145, 155):
		tilemap.set_cell(layer, Vector2i(x, 41), SOURCE, ROCKY_SURFACE, 0)
		tilemap.set_cell(layer, Vector2i(x, 42), SOURCE, ROCKY_FILL, 0)
	for x in range(148, 152):
		tilemap.set_cell(layer, Vector2i(x, 40), SOURCE, ROCKY_SURFACE, 0)
		tilemap.set_cell(layer, Vector2i(x, 41), SOURCE, ROCKY_FILL, 0)
	for x in range(149, 151):
		tilemap.set_cell(layer, Vector2i(x, 39), SOURCE, ROCKY_SURFACE, 0)
		tilemap.set_cell(layer, Vector2i(x, 40), SOURCE, ROCKY_FILL, 0)

	# =============================================
	# STEP 8: ADD ENEMIES AND COINS
	# =============================================
	print("Step 8: Adding enemies and coins...")

	var slime_scene = load("res://scenes/slime.tscn")
	var coin_scene = load("res://scenes/coin.tscn")
	var killzone_scene = load("res://scenes/killzone.tscn")

	# Remove old added sections if they exist
	for name in ["CaveSection", "ThirdFloor"]:
		var old = scene.get_node_or_null(name)
		if old:
			old.free()

	# Cave enemies container
	var cave = Node2D.new()
	cave.name = "CaveSection"
	scene.add_child(cave)
	cave.owner = scene

	# Third floor container
	var floor3 = Node2D.new()
	floor3.name = "ThirdFloor"
	scene.add_child(floor3)
	floor3.owner = scene

	if slime_scene:
		# Cave slimes (on platforms)
		var cave_slime_pos = [
			Vector2(1232, 312), Vector2(1392, 296),
			Vector2(1712, 344), Vector2(1968, 312),
		]
		for i in range(cave_slime_pos.size()):
			var s = slime_scene.instantiate()
			s.name = "CaveSlime%d" % (i+1)
			s.position = cave_slime_pos[i]
			cave.add_child(s)
			s.owner = scene

		# Third floor slimes (across all biomes)
		var f3_slime_pos = [
			# Green
			Vector2(100, 664), Vector2(300, 664), Vector2(500, 648),
			# Warm
			Vector2(800, 664), Vector2(1100, 664), Vector2(1400, 648),
			# Rocky
			Vector2(1800, 664), Vector2(2050, 664), Vector2(2300, 648),
		]
		for i in range(f3_slime_pos.size()):
			var s = slime_scene.instantiate()
			s.name = "Floor3Slime%d" % (i+1)
			s.position = f3_slime_pos[i]
			floor3.add_child(s)
			s.owner = scene

	if coin_scene:
		# Cave coins
		var cave_coins = [
			Vector2(1232, 296), Vector2(1392, 280),
			Vector2(1712, 328), Vector2(1968, 296), Vector2(1552, 312),
		]
		for i in range(cave_coins.size()):
			var c = coin_scene.instantiate()
			c.name = "CaveCoin%d" % (i+1)
			c.position = cave_coins[i]
			cave.add_child(c)
			c.owner = scene

		# Third floor coins (on obstacles and above pits)
		var f3_coins = [
			# Green
			Vector2(40, 640), Vector2(200, 616), Vector2(400, 624),
			Vector2(540, 624),
			# Warm
			Vector2(880, 616), Vector2(1070, 640),
			Vector2(1300, 600), Vector2(1500, 640),
			# Rocky
			Vector2(1920, 616), Vector2(2100, 600),
			Vector2(2250, 640), Vector2(2400, 616),
		]
		for i in range(f3_coins.size()):
			var c = coin_scene.instantiate()
			c.name = "Floor3Coin%d" % (i+1)
			c.position = f3_coins[i]
			floor3.add_child(c)
			c.owner = scene

	# Killzones in pits on third floor
	if killzone_scene:
		var pit_positions = [
			Vector2(216, 720),   # Green pit
			Vector2(680, 720),   # Biome gap 1
			Vector2(912, 720),   # Warm pit 1
			Vector2(1312, 720),  # Warm pit 2
			Vector2(1640, 720),  # Biome gap 2
			Vector2(1960, 720),  # Rocky pit
		]
		for i in range(pit_positions.size()):
			var kz = killzone_scene.instantiate()
			kz.name = "Floor3KZ%d" % (i+1)
			kz.position = pit_positions[i]
			floor3.add_child(kz)
			kz.owner = scene

			var shape = CollisionShape2D.new()
			var rect = RectangleShape2D.new()
			rect.size = Vector2(100, 10)
			shape.shape = rect
			kz.add_child(shape)
			shape.owner = scene

	# Big killzone at very bottom
	if killzone_scene:
		var bottom_kz = killzone_scene.instantiate()
		bottom_kz.name = "BottomKillzone"
		bottom_kz.position = Vector2(1100, 760)
		floor3.add_child(bottom_kz)
		bottom_kz.owner = scene
		var bshape = CollisionShape2D.new()
		var brect = RectangleShape2D.new()
		brect.size = Vector2(3500, 10)
		bshape.shape = brect
		bottom_kz.add_child(bshape)
		bshape.owner = scene

	print("=== LEVEL FIX COMPLETE ===")
	print("- Removed bad tiles from right side")
	print("- Rebuilt cave with varied platforms (stairs, zigzags, pillars)")
	print("- Third floor at Y=42 (proper spacing from cave floor)")
	print("- 3 biomes: Green, Warm, Rocky with pits and obstacles")
	print("- 4 cave slimes, 9 floor slimes, 5+12 coins, killzones")
	print("")
	print(">>> Press Ctrl+S to save! <<<")
