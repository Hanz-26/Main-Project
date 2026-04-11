@tool
extends EditorScript

## Adds killzones to catch falls into pits
## Does NOT block intentional drops between floors
## Run: Ctrl+Shift+X

func _run():
	print("=== ADDING KILLZONES ===")

	var scene = get_editor_interface().get_edited_scene_root()
	if not scene:
		print("ERROR: Open game.tscn first!")
		return

	var killzone_scene = load("res://scenes/killzone.tscn")
	if not killzone_scene:
		print("ERROR: killzone.tscn not found!")
		return

	var old = scene.get_node_or_null("ExtraKillzones")
	if old:
		old.free()

	var container = Node2D.new()
	container.name = "ExtraKillzones"
	scene.add_child(container)
	container.owner = scene

	# Killzone at the VERY bottom of the entire level
	# Any fall past this point = death
	# Bottom floor is at Y~800px, so put killzone at Y=950
	var kz = killzone_scene.instantiate()
	kz.name = "KZ_Bottom"
	kz.position = Vector2(1100, 950)
	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(4000, 20)
	shape.shape = rect
	kz.add_child(shape)
	shape.owner = scene
	container.add_child(kz)
	kz.owner = scene

	# Killzones in the pits on the bottom floor (between biomes)
	# Green-to-Warm gap (around x=46-48, Y=50 tiles = ~800px)
	var kz2 = killzone_scene.instantiate()
	kz2.name = "KZ_Pit_GreenWarm"
	kz2.position = Vector2(752, 880)  # x=47*16, below pit
	var s2 = CollisionShape2D.new()
	var r2 = RectangleShape2D.new()
	r2.size = Vector2(60, 10)
	s2.shape = r2
	kz2.add_child(s2)
	s2.owner = scene
	container.add_child(kz2)
	kz2.owner = scene

	# Warm-to-Rocky gap
	var kz3 = killzone_scene.instantiate()
	kz3.name = "KZ_Pit_WarmRocky"
	kz3.position = Vector2(1712, 880)
	var s3 = CollisionShape2D.new()
	var r3 = RectangleShape2D.new()
	r3.size = Vector2(60, 10)
	s3.shape = r3
	kz3.add_child(s3)
	s3.owner = scene
	container.add_child(kz3)
	kz3.owner = scene

	print("Added killzones:")
	print("  KZ_Bottom: Y=950 (catches any fall past the bottom floor)")
	print("  KZ_Pit_GreenWarm: between green and warm biome")
	print("  KZ_Pit_WarmRocky: between warm and rocky biome")
	print("")
	print("Falling now costs 1 heart and respawns at last safe position")
	print(">>> Press Ctrl+S to save! <<<")
