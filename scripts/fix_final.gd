@tool
extends EditorScript

## Fix sword visibility + Add checkpoints
## Run: Ctrl+Shift+X

func _run():
	print("=== FINAL FIXES ===")
	fix_sword_visibility()
	add_checkpoints()

func fix_sword_visibility():
	print("Fixing sword visibility...")
	var player_scene = load("res://scenes/player.tscn")
	if not player_scene:
		print("  ERROR: player.tscn not found")
		return

	var player = player_scene.instantiate()
	var sword = player.get_node_or_null("sword")
	if sword:
		sword.visible = true
		sword.position = Vector2(-5, -5)
		sword.scale = Vector2(0.5, 0.5)
		sword.flip_v = true
		sword.rotation = 0
		sword.region_enabled = true
		sword.region_rect = Rect2(8, 0, 16, 32)
		sword.z_index = -1
		print("  Sword: visible, on back, z_index=-1")

	var packed = PackedScene.new()
	packed.pack(player)
	ResourceSaver.save(packed, "res://scenes/player.tscn")
	player.queue_free()

func add_checkpoints():
	print("Adding checkpoints...")
	var scene = get_editor_interface().get_edited_scene_root()
	if not scene:
		print("  ERROR: Open game.tscn first!")
		return

	var old = scene.get_node_or_null("Checkpoints")
	if old:
		old.free()

	var container = Node2D.new()
	container.name = "Checkpoints"
	scene.add_child(container)
	container.owner = scene

	var checkpoint_script = load("res://scripts/checkpoint.gd")

	var checkpoints = [
		["CP_TopStart", Vector2(34, 112)],
		["CP_TopMid", Vector2(800, 112)],
		["CP_TopEnd", Vector2(2320, 112)],
		["CP_MidRight", Vector2(2320, 232)],
		["CP_MidCenter", Vector2(1200, 232)],
		["CP_MidLeft", Vector2(200, 232)],
		["CP_BotStart", Vector2(-200, 792)],
		["CP_BotGreen", Vector2(400, 792)],
		["CP_BotWarm", Vector2(1200, 792)],
		["CP_BotRocky", Vector2(1800, 792)],
		["CP_BotBoss", Vector2(2300, 792)],
	]

	for cp_data in checkpoints:
		var cp = Area2D.new()
		cp.name = cp_data[0]
		cp.position = cp_data[1]
		cp.collision_layer = 0
		cp.collision_mask = 2

		if checkpoint_script:
			cp.set_script(checkpoint_script)

		# Add to container FIRST, then set owner
		container.add_child(cp)
		cp.owner = scene

		# Now add collision shape AFTER cp is in the tree
		var shape = CollisionShape2D.new()
		var rect = RectangleShape2D.new()
		rect.size = Vector2(16, 32)
		shape.shape = rect
		cp.add_child(shape)
		shape.owner = scene  # Now this works because cp is already in the tree

	print("  Added 11 checkpoints across all 3 floors")
	print(">>> Press Ctrl+S to save! <<<")
