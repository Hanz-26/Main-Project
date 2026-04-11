@tool
extends EditorScript

## Removes the WorldBoundary killzone that blocks the drop from top to middle floor
## Run: Ctrl+Shift+X

func _run():
	print("=== FIXING DROP ZONE ===")

	var scene = get_editor_interface().get_edited_scene_root()
	if not scene:
		print("ERROR: Open game.tscn first!")
		return

	# Find the main Killzone with WorldBoundaryShape2D at (1241, 334)
	var killzone = scene.get_node_or_null("Killzone")
	if killzone:
		print("Found Killzone at: ", killzone.position)
		# Remove it - this WorldBoundary covers everything and blocks the drop
		killzone.queue_free()
		print("Removed WorldBoundary killzone at (1241, 334)")
		print("The drop from top floor to middle floor is now clear!")
	else:
		print("Killzone not found - may have already been removed")

	print(">>> Press Ctrl+S to save! <<<")
