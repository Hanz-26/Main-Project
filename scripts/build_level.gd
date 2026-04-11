@tool
extends EditorScript

## LEVEL BUILDER - Run this in Godot: File > Run (Ctrl+Shift+X)
## Extends the bottom level and adds a third floor with different biomes.
## Uses your existing world_tileset.png tiles.

func _run():
	print("=== LEVEL BUILDER STARTING ===")

	var scene = get_editor_interface().get_edited_scene_root()
	if not scene:
		print("ERROR: No scene open. Open game.tscn first!")
		return

	# Find the TileMap node
	var tilemap: TileMap = null
	for child in scene.get_children():
		if child is TileMap:
			tilemap = child
			break

	if not tilemap:
		print("ERROR: No TileMap found in scene!")
		return

	print("Found TileMap: ", tilemap.name)
	print("Tile set sources: ", tilemap.tile_set.get_source_count())

	# === TILE DEFINITIONS ===
	# Based on analysis of your existing tileset usage:
	# Source 2 = world_tileset.png
	# Atlas (0,0) alt 0 = grass/earth main tile
	# Atlas (4,0) alt 10 = dirt/fill underground
	# Atlas (1,0) alt 0 = grass surface variant
	# Atlas (6,0) alt 0 = deeper terrain variant
	# Atlas (8,0) alt 0 = alternate biome (used on right side of level)
	# Atlas (3,0) alt 0 = another grass variant

	var SOURCE = 2

	# Biome 1: Green (your existing style) - for cave platforms
	var GREEN_GRASS = Vector2i(0, 0)
	var GREEN_DIRT = Vector2i(4, 0)
	var GREEN_ALT = 0
	var DIRT_ALT = 10

	# Biome 2: Warm/autumn (atlas 8,0 area) - for third floor left
	var WARM_SURFACE = Vector2i(8, 0)
	var WARM_FILL = Vector2i(6, 0)
	var WARM_ALT = 0

	# Biome 3: Rocky variant (atlas 3,0) - for third floor right
	var ROCKY_SURFACE = Vector2i(3, 0)
	var ROCKY_FILL = Vector2i(7, 0)
	var ROCKY_ALT = 0

	var layer = 0  # Layer 0 = "Background2" (main collision layer)
	var tiles_placed = 0

	# =============================================
	# PART 1: CAVE PLATFORMS (Y=18 to Y=25)
	# Fill the gap between bottom floor and cave floor
	# These are jumping platforms in the green biome
	# =============================================
	print("Building cave platforms...")

	# Platform 1: x=75-80, Y=19
	for x in range(75, 81):
		tilemap.set_cell(layer, Vector2i(x, 19), SOURCE, GREEN_GRASS, GREEN_ALT)
		tilemap.set_cell(layer, Vector2i(x, 20), SOURCE, GREEN_DIRT, DIRT_ALT)
		tiles_placed += 2

	# Platform 2: x=86-92, Y=21
	for x in range(86, 93):
		tilemap.set_cell(layer, Vector2i(x, 21), SOURCE, GREEN_GRASS, GREEN_ALT)
		tilemap.set_cell(layer, Vector2i(x, 22), SOURCE, GREEN_DIRT, DIRT_ALT)
		tiles_placed += 2

	# Platform 3: x=97-102, Y=19
	for x in range(97, 103):
		tilemap.set_cell(layer, Vector2i(x, 19), SOURCE, GREEN_GRASS, GREEN_ALT)
		tilemap.set_cell(layer, Vector2i(x, 20), SOURCE, GREEN_DIRT, DIRT_ALT)
		tiles_placed += 2

	# Platform 4: x=107-113, Y=22
	for x in range(107, 114):
		tilemap.set_cell(layer, Vector2i(x, 22), SOURCE, GREEN_GRASS, GREEN_ALT)
		tilemap.set_cell(layer, Vector2i(x, 23), SOURCE, GREEN_DIRT, DIRT_ALT)
		tiles_placed += 2

	# Platform 5: x=118-124, Y=20
	for x in range(118, 125):
		tilemap.set_cell(layer, Vector2i(x, 20), SOURCE, GREEN_GRASS, GREEN_ALT)
		tilemap.set_cell(layer, Vector2i(x, 21), SOURCE, GREEN_DIRT, DIRT_ALT)
		tiles_placed += 2

	# Platform 6: x=130-136, Y=23
	for x in range(130, 137):
		tilemap.set_cell(layer, Vector2i(x, 23), SOURCE, GREEN_GRASS, GREEN_ALT)
		tilemap.set_cell(layer, Vector2i(x, 24), SOURCE, GREEN_DIRT, DIRT_ALT)
		tiles_placed += 2

	# Platform 7: x=140-146, Y=21
	for x in range(140, 147):
		tilemap.set_cell(layer, Vector2i(x, 21), SOURCE, GREEN_GRASS, GREEN_ALT)
		tilemap.set_cell(layer, Vector2i(x, 22), SOURCE, GREEN_DIRT, DIRT_ALT)
		tiles_placed += 2

	# =============================================
	# PART 2: STEPPING PLATFORMS (Y=27 down to Y=33)
	# Connecting cave floor to the new third floor
	# =============================================
	print("Building stepping platforms to third floor...")

	# Left descent: green biome
	for x in range(25, 31):
		tilemap.set_cell(layer, Vector2i(x, 29), SOURCE, GREEN_GRASS, GREEN_ALT)
		tilemap.set_cell(layer, Vector2i(x, 30), SOURCE, GREEN_DIRT, DIRT_ALT)
		tiles_placed += 2
	for x in range(35, 41):
		tilemap.set_cell(layer, Vector2i(x, 31), SOURCE, GREEN_GRASS, GREEN_ALT)
		tilemap.set_cell(layer, Vector2i(x, 32), SOURCE, GREEN_DIRT, DIRT_ALT)
		tiles_placed += 2

	# Middle descent: warm biome transition
	for x in range(75, 81):
		tilemap.set_cell(layer, Vector2i(x, 29), SOURCE, WARM_SURFACE, WARM_ALT)
		tilemap.set_cell(layer, Vector2i(x, 30), SOURCE, WARM_FILL, WARM_ALT)
		tiles_placed += 2
	for x in range(85, 91):
		tilemap.set_cell(layer, Vector2i(x, 31), SOURCE, WARM_SURFACE, WARM_ALT)
		tilemap.set_cell(layer, Vector2i(x, 32), SOURCE, WARM_FILL, WARM_ALT)
		tiles_placed += 2

	# Right descent: rocky biome
	for x in range(125, 131):
		tilemap.set_cell(layer, Vector2i(x, 29), SOURCE, ROCKY_SURFACE, ROCKY_ALT)
		tilemap.set_cell(layer, Vector2i(x, 30), SOURCE, ROCKY_FILL, ROCKY_ALT)
		tiles_placed += 2
	for x in range(135, 141):
		tilemap.set_cell(layer, Vector2i(x, 31), SOURCE, ROCKY_SURFACE, ROCKY_ALT)
		tilemap.set_cell(layer, Vector2i(x, 32), SOURCE, ROCKY_FILL, ROCKY_ALT)
		tiles_placed += 2

	# =============================================
	# PART 3: THIRD FLOOR (Y=33-35)
	# Three biomes across the floor:
	#   Left (x=-20 to 50): Green biome
	#   Middle (x=51 to 110): Warm/autumn biome
	#   Right (x=111 to 157): Rocky biome
	# =============================================
	print("Building third floor with 3 biomes...")

	# --- GREEN BIOME (left section) ---
	for x in range(-20, 51):
		tilemap.set_cell(layer, Vector2i(x, 33), SOURCE, GREEN_GRASS, GREEN_ALT)
		tilemap.set_cell(layer, Vector2i(x, 34), SOURCE, GREEN_DIRT, DIRT_ALT)
		tilemap.set_cell(layer, Vector2i(x, 35), SOURCE, GREEN_DIRT, DIRT_ALT)
		tiles_placed += 3

	# --- WARM BIOME (middle section) ---
	for x in range(51, 111):
		tilemap.set_cell(layer, Vector2i(x, 33), SOURCE, WARM_SURFACE, WARM_ALT)
		tilemap.set_cell(layer, Vector2i(x, 34), SOURCE, WARM_FILL, WARM_ALT)
		tilemap.set_cell(layer, Vector2i(x, 35), SOURCE, WARM_FILL, WARM_ALT)
		tiles_placed += 3

	# --- ROCKY BIOME (right section) ---
	for x in range(111, 158):
		tilemap.set_cell(layer, Vector2i(x, 33), SOURCE, ROCKY_SURFACE, ROCKY_ALT)
		tilemap.set_cell(layer, Vector2i(x, 34), SOURCE, ROCKY_FILL, ROCKY_ALT)
		tilemap.set_cell(layer, Vector2i(x, 35), SOURCE, ROCKY_FILL, ROCKY_ALT)
		tiles_placed += 3

	# =============================================
	# PART 4: OBSTACLES ON THIRD FLOOR
	# Raised platforms for jumping variety
	# =============================================
	print("Adding obstacles on third floor...")

	# Green biome obstacles
	for x in range(5, 10):
		tilemap.set_cell(layer, Vector2i(x, 31), SOURCE, GREEN_GRASS, GREEN_ALT)
		tilemap.set_cell(layer, Vector2i(x, 32), SOURCE, GREEN_DIRT, DIRT_ALT)
		tiles_placed += 2
	for x in range(20, 24):
		tilemap.set_cell(layer, Vector2i(x, 30), SOURCE, GREEN_GRASS, GREEN_ALT)
		tilemap.set_cell(layer, Vector2i(x, 31), SOURCE, GREEN_DIRT, DIRT_ALT)
		tilemap.set_cell(layer, Vector2i(x, 32), SOURCE, GREEN_DIRT, DIRT_ALT)
		tiles_placed += 3
	for x in range(38, 43):
		tilemap.set_cell(layer, Vector2i(x, 31), SOURCE, GREEN_GRASS, GREEN_ALT)
		tilemap.set_cell(layer, Vector2i(x, 32), SOURCE, GREEN_DIRT, DIRT_ALT)
		tiles_placed += 2

	# Warm biome obstacles
	for x in range(60, 65):
		tilemap.set_cell(layer, Vector2i(x, 31), SOURCE, WARM_SURFACE, WARM_ALT)
		tilemap.set_cell(layer, Vector2i(x, 32), SOURCE, WARM_FILL, WARM_ALT)
		tiles_placed += 2
	for x in range(75, 80):
		tilemap.set_cell(layer, Vector2i(x, 30), SOURCE, WARM_SURFACE, WARM_ALT)
		tilemap.set_cell(layer, Vector2i(x, 31), SOURCE, WARM_FILL, WARM_ALT)
		tilemap.set_cell(layer, Vector2i(x, 32), SOURCE, WARM_FILL, WARM_ALT)
		tiles_placed += 3
	for x in range(95, 100):
		tilemap.set_cell(layer, Vector2i(x, 31), SOURCE, WARM_SURFACE, WARM_ALT)
		tilemap.set_cell(layer, Vector2i(x, 32), SOURCE, WARM_FILL, WARM_ALT)
		tiles_placed += 2

	# Rocky biome obstacles
	for x in range(118, 123):
		tilemap.set_cell(layer, Vector2i(x, 31), SOURCE, ROCKY_SURFACE, ROCKY_ALT)
		tilemap.set_cell(layer, Vector2i(x, 32), SOURCE, ROCKY_FILL, ROCKY_ALT)
		tiles_placed += 2
	for x in range(135, 140):
		tilemap.set_cell(layer, Vector2i(x, 30), SOURCE, ROCKY_SURFACE, ROCKY_ALT)
		tilemap.set_cell(layer, Vector2i(x, 31), SOURCE, ROCKY_FILL, ROCKY_ALT)
		tilemap.set_cell(layer, Vector2i(x, 32), SOURCE, ROCKY_FILL, ROCKY_ALT)
		tiles_placed += 3

	# =============================================
	# PART 5: WALLS ON SIDES
	# Close off the left and right edges
	# =============================================
	print("Adding side walls...")
	for y in range(27, 36):
		tilemap.set_cell(layer, Vector2i(-20, y), SOURCE, GREEN_DIRT, DIRT_ALT)
		tilemap.set_cell(layer, Vector2i(-19, y), SOURCE, GREEN_DIRT, DIRT_ALT)
		tilemap.set_cell(layer, Vector2i(157, y), SOURCE, ROCKY_FILL, ROCKY_ALT)
		tilemap.set_cell(layer, Vector2i(156, y), SOURCE, ROCKY_FILL, ROCKY_ALT)
		tiles_placed += 4

	# =============================================
	# PART 6: GAPS IN CAVE FLOOR (Y=27)
	# Remove some tiles at Y=27 to create drop-through points
	# =============================================
	print("Creating drop-through gaps in cave floor...")
	for x in range(30, 34):
		tilemap.erase_cell(layer, Vector2i(x, 27))
	for x in range(80, 84):
		tilemap.erase_cell(layer, Vector2i(x, 27))
	for x in range(130, 134):
		tilemap.erase_cell(layer, Vector2i(x, 27))

	# =============================================
	# PART 7: ADD ENEMIES AND COINS AS NODES
	# =============================================
	print("Adding enemies and coins...")

	var slime_scene = load("res://scenes/slime.tscn")
	var coin_scene = load("res://scenes/coin.tscn")
	var killzone_scene = load("res://scenes/killzone.tscn")

	# Create organized containers
	var cave_section = Node2D.new()
	cave_section.name = "CaveSection"
	scene.add_child(cave_section)
	cave_section.owner = scene

	var floor3_section = Node2D.new()
	floor3_section.name = "ThirdFloor"
	scene.add_child(floor3_section)
	floor3_section.owner = scene

	# --- CAVE ENEMIES (on the platforms) ---
	if slime_scene:
		var positions = [
			Vector2(1248, 296),  # Platform 1
			Vector2(1424, 328),  # Platform 2
			Vector2(1600, 296),  # Platform 3
			Vector2(1808, 344),  # Platform 4
		]
		for i in range(positions.size()):
			var slime = slime_scene.instantiate()
			slime.name = "CaveSlime%d" % (i + 1)
			slime.position = positions[i]
			cave_section.add_child(slime)
			slime.owner = scene

	# --- CAVE COINS ---
	if coin_scene:
		var coin_positions = [
			Vector2(1240, 288), Vector2(1440, 320),
			Vector2(1600, 288), Vector2(1808, 336),
			Vector2(2000, 320),
		]
		for i in range(coin_positions.size()):
			var coin = coin_scene.instantiate()
			coin.name = "CaveCoin%d" % (i + 1)
			coin.position = coin_positions[i]
			cave_section.add_child(coin)
			coin.owner = scene

	# --- THIRD FLOOR ENEMIES ---
	if slime_scene:
		# Green biome slimes
		var floor3_positions = [
			Vector2(160, 520), Vector2(320, 520), Vector2(480, 520),
			# Warm biome slimes
			Vector2(960, 520), Vector2(1120, 520), Vector2(1280, 520),
			# Rocky biome slimes
			Vector2(1920, 520), Vector2(2080, 520), Vector2(2240, 520),
		]
		for i in range(floor3_positions.size()):
			var slime = slime_scene.instantiate()
			slime.name = "Floor3Slime%d" % (i + 1)
			slime.position = floor3_positions[i]
			floor3_section.add_child(slime)
			slime.owner = scene

	# --- THIRD FLOOR COINS ---
	if coin_scene:
		var floor3_coins = [
			# Green biome
			Vector2(120, 500), Vector2(280, 468), Vector2(440, 500),
			# Warm biome
			Vector2(880, 468), Vector2(1040, 500), Vector2(1200, 468),
			# Rocky biome
			Vector2(1840, 500), Vector2(2000, 468), Vector2(2160, 500),
			Vector2(2320, 468),
		]
		for i in range(floor3_coins.size()):
			var coin = coin_scene.instantiate()
			coin.name = "Floor3Coin%d" % (i + 1)
			coin.position = floor3_coins[i]
			floor3_section.add_child(coin)
			coin.owner = scene

	# --- KILLZONE below third floor ---
	if killzone_scene:
		var kz = killzone_scene.instantiate()
		kz.name = "Killzone_Floor3"
		kz.position = Vector2(1100, 600)
		floor3_section.add_child(kz)
		kz.owner = scene

		var shape = CollisionShape2D.new()
		shape.name = "CollisionShape2D"
		var rect = RectangleShape2D.new()
		rect.size = Vector2(3000, 10)
		shape.shape = rect
		shape.position = Vector2(0, 0)
		kz.add_child(shape)
		shape.owner = scene

	print("=== LEVEL BUILDER COMPLETE ===")
	print("Tiles placed: ", tiles_placed)
	print("Cave: 7 platforms with 4 slimes and 5 coins")
	print("Third floor: 3 biomes (green, warm, rocky)")
	print("Third floor: 9 slimes, 10 coins, obstacles")
	print("")
	print("IMPORTANT: Save the scene (Ctrl+S) to keep changes!")
