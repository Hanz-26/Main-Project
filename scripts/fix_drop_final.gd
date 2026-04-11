@tool
extends EditorScript

## Remove killzones blocking the drop paths + add checkpoint flag
## Run: Ctrl+Shift+X

func _run():
	print("=== FIXING DROPS + ADDING CHECKPOINT FLAG ===")

	var scene = get_editor_interface().get_edited_scene_root()
	if not scene:
		print("ERROR: Open game.tscn first!")
		return

	# Remove Killzone_Floor3 at Y=600 (blocks drop to bottom floor)
	# It's inside a ThirdFloor or similar container
	_remove_killzone_recursive(scene, "Killzone_Floor3")

	# Remove BottomKillzone at Y=900 (too aggressive)
	_remove_killzone_recursive(scene, "BottomKillzone")

	# Keep only KZ_Bottom at Y=950 as the absolute death floor
	# Keep KZ_Pit_GreenWarm and KZ_Pit_WarmRocky (in biome pits)

	# Also remove Killzone2 at (78, 30) if it's causing issues
	var kz2 = scene.get_node_or_null("Killzone2")
	if kz2:
		print("Removed Killzone2 at ", kz2.position)
		kz2.queue_free()

	print("")
	print("=== DONE ===")
	print("Only remaining killzones:")
	print("  KZ_Bottom at Y=950 (absolute bottom)")
	print("  KZ_Pit_GreenWarm at Y=880 (biome gap)")
	print("  KZ_Pit_WarmRocky at Y=880 (biome gap)")
	print(">>> Press Ctrl+S to save! <<<")

func _remove_killzone_recursive(node: Node, target_name: String):
	for child in node.get_children():
		if child.name == target_name:
			print("Removed ", target_name, " at ", child.position, " (parent: ", node.name, ")")
			child.queue_free()
			return
		_remove_killzone_recursive(child, target_name)
