@tool
extends EditorScript

## REBUILD LEVEL - Complete redo of the bottom sections
## Run: Ctrl+Shift+X in Script editor
## Creates terrain like a real platformer level with hills, valleys,
## varied heights, and proper spacing

func _run():
	print("=== REBUILDING LEVEL ===")

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
		print("ERROR: No TileMap found!")
		return

	var SOURCE = 2
	var layer = 0
	var GREEN_GRASS = Vector2i(0, 0)
	var GREEN_DIRT = Vector2i(4, 0)
	var WARM_SURFACE = Vector2i(8, 0)
	var WARM_FILL = Vector2i(6, 0)
	var ROCKY_SURFACE = Vector2i(3, 0)
	var ROCKY_FILL = Vector2i(7, 0)
	var GRASS_VAR = Vector2i(1, 0)

	# =============================================
	# STEP 1: NUKE EVERYTHING I PREVIOUSLY ADDED
	# Clear Y=18 to Y=60 except existing cave floor at Y=27
	# =============================================
	print("Clearing old additions...")
	for y in range(18, 60):
		for x in range(-25, 165):
			# Don't erase the existing cave floor (Y=27) or above
			if y >= 28 or (y >= 18 and y <= 26):
				# For Y=18-26, only erase tiles in the platform ranges I added
				if y <= 26:
					var src = tilemap.get_cell_source_id(layer, Vector2i(x, y))
					if src == -1:
						continue
					# Only erase tiles in ranges where I added platforms
					var dominated = false
					for rng in [[72,80],[84,88],[93,99],[104,109],[112,117],[121,126],[130,140],[140,147]]:
						if x >= rng[0] and x <= rng[1]:
							dominated = true
							break
					if dominated:
						tilemap.erase_cell(layer, Vector2i(x, y))
				else:
					tilemap.erase_cell(layer, Vector2i(x, y))

	# Remove old node groups
	for name in ["CaveSection", "ThirdFloor"]:
		var old = scene.get_node_or_null(name)
		if old:
			old.free()

	# =============================================
	# STEP 2: CAVE PLATFORMS (Y=18-25)
	# Interesting shapes, not just flat rectangles
	# =============================================
	print("Building cave platforms...")

	# Entry staircase from left
	_place_row(tilemap, layer, 73, 75, 18, SOURCE, GREEN_GRASS, 0)
	_place_row(tilemap, layer, 73, 76, 19, SOURCE, GREEN_DIRT, 10)
	_place_row(tilemap, layer, 76, 79, 20, SOURCE, GREEN_GRASS, 0)
	_place_row(tilemap, layer, 76, 79, 21, SOURCE, GREEN_DIRT, 10)

	# Floating stepping stones
	_place_row(tilemap, layer, 83, 85, 19, SOURCE, GREEN_GRASS, 0)
	_place_row(tilemap, layer, 89, 91, 21, SOURCE, GREEN_GRASS, 0)
	_place_row(tilemap, layer, 95, 97, 19, SOURCE, GREEN_GRASS, 0)

	# U-shaped valley
	_place_col(tilemap, layer, 102, 20, 24, SOURCE, GREEN_DIRT, 10)
	_place_row(tilemap, layer, 102, 110, 24, SOURCE, GREEN_DIRT, 10)
	_place_row(tilemap, layer, 102, 110, 23, SOURCE, GREEN_GRASS, 0)
	_place_col(tilemap, layer, 110, 20, 24, SOURCE, GREEN_DIRT, 10)
	_place_row(tilemap, layer, 102, 104, 20, SOURCE, GREEN_GRASS, 0)
	_place_row(tilemap, layer, 108, 110, 20, SOURCE, GREEN_GRASS, 0)

	# Zigzag platforms to right
	_place_row(tilemap, layer, 115, 118, 21, SOURCE, GREEN_GRASS, 0)
	_place_row(tilemap, layer, 122, 125, 19, SOURCE, GREEN_GRASS, 0)
	_place_row(tilemap, layer, 129, 132, 22, SOURCE, GREEN_GRASS, 0)
	_place_row(tilemap, layer, 129, 132, 23, SOURCE, GREEN_DIRT, 10)

	# Exit hill to right wall
	_place_row(tilemap, layer, 137, 142, 20, SOURCE, GREEN_GRASS, 0)
	_place_row(tilemap, layer, 137, 142, 21, SOURCE, GREEN_DIRT, 10)
	_place_row(tilemap, layer, 139, 141, 19, SOURCE, GREEN_GRASS, 0)
	_place_row(tilemap, layer, 139, 141, 20, SOURCE, GREEN_DIRT, 10)

	# =============================================
	# STEP 3: DROP-THROUGH GAPS in cave floor (Y=27)
	# =============================================
	print("Creating drop gaps...")
	for x in range(28, 33):
		tilemap.erase_cell(layer, Vector2i(x, 27))
	for x in range(78, 83):
		tilemap.erase_cell(layer, Vector2i(x, 27))
	for x in range(128, 133):
		tilemap.erase_cell(layer, Vector2i(x, 27))

	# =============================================
	# STEP 4: THIRD FLOOR - Y=50 base (23 tiles below cave floor)
	# This gives HUGE gap like image1 reference
	# Terrain with hills, valleys, overhangs, pits
	# =============================================
	print("Building third floor with terrain variation...")

	# The height map defines the TOP of the ground at each x position
	# Lower number = higher terrain (closer to top of screen)
	# -1 = gap/pit (no ground)

	# GREEN BIOME (x=-20 to 45)
	var green_heights = []
	# Flat start with small hill
	for x in range(-20, -10):
		green_heights.append(50)
	# Rising hill
	green_heights.append(49) # x=-10
	green_heights.append(49)
	green_heights.append(48)
	green_heights.append(48)
	green_heights.append(47) # x=-6
	green_heights.append(47)
	green_heights.append(47)
	green_heights.append(48) # x=-3
	green_heights.append(49)
	green_heights.append(50) # x=-1
	# Valley
	for x in range(5):
		green_heights.append(50) # x=0-4
	# Pit
	green_heights.append(-1) # x=5
	green_heights.append(-1)
	green_heights.append(-1) # x=7
	# Back up
	green_heights.append(50) # x=8
	green_heights.append(49)
	green_heights.append(49)
	green_heights.append(48) # x=11
	green_heights.append(48)
	green_heights.append(48)
	green_heights.append(48) # x=14 - plateau
	green_heights.append(48)
	green_heights.append(49) # x=16
	green_heights.append(49)
	green_heights.append(50) # x=18
	# Flat section
	for x in range(7):
		green_heights.append(50) # x=19-25
	# Big hill
	green_heights.append(49) # x=26
	green_heights.append(48)
	green_heights.append(47)
	green_heights.append(46) # x=29
	green_heights.append(46)
	green_heights.append(46)
	green_heights.append(47) # x=32
	green_heights.append(48)
	green_heights.append(49) # x=34
	green_heights.append(50)
	# Flat to biome transition
	for x in range(10):
		green_heights.append(50) # x=36-45

	# Place green biome terrain
	for i in range(green_heights.size()):
		var x = -20 + i
		var h = green_heights[i]
		if h == -1:
			continue  # pit
		# Place grass on top, dirt below (4 tiles thick)
		tilemap.set_cell(layer, Vector2i(x, h), SOURCE, GREEN_GRASS, 0)
		for dy in range(1, 5):
			tilemap.set_cell(layer, Vector2i(x, h + dy), SOURCE, GREEN_DIRT, 10)

	# WARM BIOME (x=46 to 105)
	# Gap between biomes (x=46-48)
	var warm_start = 49
	var warm_heights = []
	# Staircase entry
	warm_heights.append(52) # x=49
	warm_heights.append(51)
	warm_heights.append(50) # x=51
	warm_heights.append(50)
	warm_heights.append(50)
	warm_heights.append(50) # x=54
	# Rising terrain
	warm_heights.append(49) # x=55
	warm_heights.append(49)
	warm_heights.append(48)
	warm_heights.append(48) # x=58
	warm_heights.append(48)
	warm_heights.append(49) # x=60
	warm_heights.append(50)
	# Pit
	warm_heights.append(-1) # x=62
	warm_heights.append(-1)
	warm_heights.append(-1) # x=64
	# Mesa/plateau
	warm_heights.append(48) # x=65
	warm_heights.append(47)
	warm_heights.append(46)
	warm_heights.append(46) # x=68
	warm_heights.append(46)
	warm_heights.append(46)
	warm_heights.append(46) # x=71 - flat top
	warm_heights.append(46)
	warm_heights.append(47)
	warm_heights.append(48) # x=74
	warm_heights.append(49)
	warm_heights.append(50) # x=76
	# Valley
	warm_heights.append(50)
	warm_heights.append(51) # x=78
	warm_heights.append(51)
	warm_heights.append(51) # x=80 - low valley
	warm_heights.append(51)
	warm_heights.append(50) # x=82
	warm_heights.append(50)
	# Another pit
	warm_heights.append(-1) # x=84
	warm_heights.append(-1)
	warm_heights.append(-1) # x=86
	# Final section
	warm_heights.append(50) # x=87
	warm_heights.append(49)
	warm_heights.append(49)
	warm_heights.append(48) # x=90
	warm_heights.append(48)
	warm_heights.append(49)
	warm_heights.append(50) # x=93
	for x in range(12):
		warm_heights.append(50) # x=94-105

	# Place warm biome
	for i in range(warm_heights.size()):
		var x = warm_start + i
		var h = warm_heights[i]
		if h == -1:
			continue
		tilemap.set_cell(layer, Vector2i(x, h), SOURCE, WARM_SURFACE, 0)
		for dy in range(1, 5):
			tilemap.set_cell(layer, Vector2i(x, h + dy), SOURCE, WARM_FILL, 0)

	# ROCKY BIOME (x=108 to 157)
	# Gap between biomes (x=106-108)
	var rocky_start = 109
	var rocky_heights = []
	# Dramatic entry - tall cliff
	rocky_heights.append(52) # x=109
	rocky_heights.append(51)
	rocky_heights.append(50) # x=111
	rocky_heights.append(49)
	rocky_heights.append(48) # x=113
	rocky_heights.append(48)
	rocky_heights.append(48)
	# Pit
	rocky_heights.append(-1) # x=116
	rocky_heights.append(-1)
	rocky_heights.append(-1) # x=118
	# Mountain
	rocky_heights.append(50) # x=119
	rocky_heights.append(49)
	rocky_heights.append(48)
	rocky_heights.append(47) # x=122
	rocky_heights.append(46)
	rocky_heights.append(45) # x=124 - peak!
	rocky_heights.append(45)
	rocky_heights.append(46) # x=126
	rocky_heights.append(47)
	rocky_heights.append(48)
	rocky_heights.append(49) # x=129
	rocky_heights.append(50)
	# Flat
	rocky_heights.append(50) # x=131
	rocky_heights.append(50)
	# Pit
	rocky_heights.append(-1) # x=133
	rocky_heights.append(-1)
	rocky_heights.append(-1)
	rocky_heights.append(-1) # x=136 - wide pit!
	# Final hill
	rocky_heights.append(50) # x=137
	rocky_heights.append(49)
	rocky_heights.append(48)
	rocky_heights.append(48) # x=140
	rocky_heights.append(48)
	rocky_heights.append(49)
	rocky_heights.append(50) # x=143
	# Flat end
	for x in range(14):
		rocky_heights.append(50) # x=144-157

	# Place rocky biome
	for i in range(rocky_heights.size()):
		var x = rocky_start + i
		if x > 157:
			break
		var h = rocky_heights[i]
		if h == -1:
			continue
		tilemap.set_cell(layer, Vector2i(x, h), SOURCE, ROCKY_SURFACE, 0)
		for dy in range(1, 5):
			tilemap.set_cell(layer, Vector2i(x, h + dy), SOURCE, ROCKY_FILL, 0)

	# =============================================
	# STEP 5: FLOATING PLATFORMS over pits and in gaps
	# =============================================
	print("Adding floating platforms over pits...")

	# Green pit (x=5-7) - floating platform
	_place_row(tilemap, layer, 5, 7, 47, SOURCE, GREEN_GRASS, 0)

	# Warm pit 1 (x=62-64)
	_place_row(tilemap, layer, 62, 63, 46, SOURCE, WARM_SURFACE, 0)
	_place_row(tilemap, layer, 64, 65, 44, SOURCE, WARM_SURFACE, 0)

	# Warm pit 2 (x=84-86)
	tilemap.set_cell(layer, Vector2i(85, 47), SOURCE, WARM_SURFACE, 0)

	# Biome gap 1 (x=46-48)
	_place_row(tilemap, layer, 46, 48, 48, SOURCE, GRASS_VAR, 0)

	# Biome gap 2 (x=106-108)
	_place_row(tilemap, layer, 106, 108, 48, SOURCE, ROCKY_SURFACE, 0)

	# Rocky pit 1 (x=116-118)
	tilemap.set_cell(layer, Vector2i(117, 46), SOURCE, ROCKY_SURFACE, 0)

	# Rocky pit 2 (x=133-136) - stepping stones
	tilemap.set_cell(layer, Vector2i(134, 47), SOURCE, ROCKY_SURFACE, 0)
	tilemap.set_cell(layer, Vector2i(136, 46), SOURCE, ROCKY_SURFACE, 0)

	# =============================================
	# STEP 6: DESCENT PLATFORMS (cave floor Y=27 to third floor Y=50)
	# Need stepping platforms across this 23-tile gap
	# =============================================
	print("Adding descent platforms...")

	# Left descent (through gap at x=28-32)
	_place_row(tilemap, layer, 26, 30, 30, SOURCE, GREEN_GRASS, 0)
	_place_row(tilemap, layer, 22, 26, 34, SOURCE, GREEN_GRASS, 0)
	_place_row(tilemap, layer, 27, 31, 38, SOURCE, GREEN_GRASS, 0)
	_place_row(tilemap, layer, 22, 26, 42, SOURCE, GREEN_GRASS, 0)
	_place_row(tilemap, layer, 27, 31, 46, SOURCE, GREEN_GRASS, 0)

	# Middle descent (through gap at x=78-82)
	_place_row(tilemap, layer, 76, 80, 30, SOURCE, WARM_SURFACE, 0)
	_place_row(tilemap, layer, 82, 86, 34, SOURCE, WARM_SURFACE, 0)
	_place_row(tilemap, layer, 76, 80, 38, SOURCE, WARM_SURFACE, 0)
	_place_row(tilemap, layer, 82, 86, 42, SOURCE, WARM_SURFACE, 0)
	_place_row(tilemap, layer, 76, 80, 46, SOURCE, WARM_SURFACE, 0)

	# Right descent (through gap at x=128-132)
	_place_row(tilemap, layer, 126, 130, 30, SOURCE, ROCKY_SURFACE, 0)
	_place_row(tilemap, layer, 132, 136, 34, SOURCE, ROCKY_SURFACE, 0)
	_place_row(tilemap, layer, 126, 130, 38, SOURCE, ROCKY_SURFACE, 0)
	_place_row(tilemap, layer, 132, 136, 42, SOURCE, ROCKY_SURFACE, 0)
	_place_row(tilemap, layer, 126, 130, 46, SOURCE, ROCKY_SURFACE, 0)

	# Side walls for the entire descent + third floor area
	for y in range(28, 55):
		tilemap.set_cell(layer, Vector2i(-20, y), SOURCE, GREEN_DIRT, 10)
		tilemap.set_cell(layer, Vector2i(-19, y), SOURCE, GREEN_DIRT, 10)
		tilemap.set_cell(layer, Vector2i(157, y), SOURCE, ROCKY_FILL, 0)
		tilemap.set_cell(layer, Vector2i(156, y), SOURCE, ROCKY_FILL, 0)

	# =============================================
	# STEP 7: ENEMIES AND COINS
	# =============================================
	print("Adding enemies and coins...")

	var slime_scene = load("res://scenes/slime.tscn")
	var coin_scene = load("res://scenes/coin.tscn")
	var killzone_scene = load("res://scenes/killzone.tscn")

	var cave = Node2D.new()
	cave.name = "CaveSection"
	scene.add_child(cave)
	cave.owner = scene

	var floor3 = Node2D.new()
	floor3.name = "ThirdFloor"
	scene.add_child(floor3)
	floor3.owner = scene

	if slime_scene:
		# Cave slimes
		for pos in [Vector2(1232, 296), Vector2(1440, 328), Vector2(1712, 312), Vector2(1936, 320)]:
			var s = slime_scene.instantiate()
			s.name = "CS%d" % randi()
			s.position = pos
			cave.add_child(s)
			s.owner = scene

		# Third floor slimes - on the terrain at various heights
		# Y position = height * 16 - 8 (center of tile above ground)
		for pos in [
			Vector2(-80, 744), Vector2(160, 760), Vector2(350, 792),
			Vector2(880, 728), Vector2(1060, 776), Vector2(1136, 728),
			Vector2(1792, 760), Vector2(1936, 712), Vector2(2240, 760),
		]:
			var s = slime_scene.instantiate()
			s.name = "FS%d" % randi()
			s.position = pos
			floor3.add_child(s)
			s.owner = scene

	if coin_scene:
		for pos in [
			# Cave coins
			Vector2(1240, 280), Vector2(1440, 312), Vector2(1712, 296),
			# Third floor coins - above interesting terrain features
			Vector2(-112, 728), Vector2(96, 720), Vector2(200, 752),
			Vector2(464, 736), Vector2(880, 712), Vector2(1056, 760),
			Vector2(1120, 712), Vector2(1792, 744), Vector2(1968, 704),
			Vector2(2240, 744), Vector2(2400, 760),
		]:
			var c = coin_scene.instantiate()
			c.name = "C%d" % randi()
			c.position = pos
			floor3.add_child(c)
			c.owner = scene

	# Bottom killzone
	if killzone_scene:
		var kz = killzone_scene.instantiate()
		kz.name = "BottomKillzone"
		kz.position = Vector2(1100, 900)
		floor3.add_child(kz)
		kz.owner = scene
		var shape = CollisionShape2D.new()
		var rect = RectangleShape2D.new()
		rect.size = Vector2(4000, 10)
		shape.shape = rect
		kz.add_child(shape)
		shape.owner = scene

	print("=== REBUILD COMPLETE ===")
	print("Cave: varied platforms (stairs, U-shape, zigzags, stepping stones)")
	print("Third floor at Y=50 (23 tiles below cave = MUCH more spacing)")
	print("3 biomes with hills, valleys, mountains, pits, plateaus")
	print("Floating platforms over pits, descent zigzag platforms")
	print(">>> Press Ctrl+S to save! <<<")

# Helper: place a horizontal row of tiles
func _place_row(tilemap: TileMap, layer: int, x_start: int, x_end: int, y: int, source: int, atlas: Vector2i, alt: int):
	for x in range(x_start, x_end + 1):
		tilemap.set_cell(layer, Vector2i(x, y), source, atlas, alt)

# Helper: place a vertical column of tiles
func _place_col(tilemap: TileMap, layer: int, x: int, y_start: int, y_end: int, source: int, atlas: Vector2i, alt: int):
	for y in range(y_start, y_end + 1):
		tilemap.set_cell(layer, Vector2i(x, y), source, atlas, alt)
