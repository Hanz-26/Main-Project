@tool
extends EditorScript

## DEBUG: Lists ALL Area2D nodes in the scene that could kill the player
## Run: Ctrl+Shift+X

func _run():
	print("=== SEARCHING FOR ALL KILLZONES ===")
	var scene = get_editor_interface().get_edited_scene_root()
	if not scene:
		print("ERROR: Open game.tscn first!")
		return

	_find_areas(scene, "")

func _find_areas(node: Node, path: String):
	var current_path = path + "/" + node.name

	if node is Area2D:
		var script_name = ""
		if node.get_script():
			script_name = node.get_script().resource_path

		# Check collision shapes
		var shape_info = ""
		for child in node.get_children():
			if child is CollisionShape2D:
				if child.shape is WorldBoundaryShape2D:
					shape_info = "WorldBoundary"
				elif child.shape is RectangleShape2D:
					shape_info = "Rect(" + str(child.shape.size) + ") offset=" + str(child.position)

		print("  AREA2D: ", current_path)
		print("    Position: ", node.global_position)
		print("    Script: ", script_name)
		print("    Layer: ", node.collision_layer, " Mask: ", node.collision_mask)
		print("    Shape: ", shape_info)
		print("")

	for child in node.get_children():
		_find_areas(child, current_path)
