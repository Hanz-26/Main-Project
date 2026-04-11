@tool
extends EditorScript

## Removes killzones that block the drop from top to middle floor
## Run: Ctrl+Shift+X

func _run():
	print("=== REMOVING BLOCKING KILLZONES ===")

	var scene = get_editor_interface().get_edited_scene_root()
	if not scene:
		print("ERROR: Open game.tscn first!")
		return

	# Killzone3 at (1855, 166) - blocks the drop area
	var kz3 = scene.get_node_or_null("Killzone3")
	if kz3:
		print("Removed Killzone3 at ", kz3.position)
		kz3.queue_free()

	# Killzone4 at (311, 295) with HUGE 2511px wide strip
	# Its collision shape is at offset (650.5, -185.5) = Y~110
	# This covers the entire gap between top and middle floor
	var kz4 = scene.get_node_or_null("Killzone4")
	if kz4:
		print("Removed Killzone4 at ", kz4.position, " (2511px wide strip)")
		kz4.queue_free()

	# Killzone2 at (78, 30) - near player start, might be needed
	# Leave it for now

	print("")
	print("Drop zone is now clear!")
	print(">>> Press Ctrl+S to save! <<<")
