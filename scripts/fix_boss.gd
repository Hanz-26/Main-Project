@tool
extends EditorScript

## Swaps the boss script to simple_boss.gd so it moves and works
## Run: Ctrl+Shift+X

func _run():
	var scene = get_editor_interface().get_edited_scene_root()
	if not scene:
		print("ERROR: Open game.tscn first!")
		return

	var boss = scene.get_node_or_null("BossArea/Necromancer")
	if not boss:
		# Try finding it differently
		for child in scene.get_children():
			if child.name == "BossArea":
				for c in child.get_children():
					if "ecromancer" in c.name or "boss" in c.name.to_lower():
						boss = c
						break

	if not boss:
		print("ERROR: No boss node found! Run connect_levels.gd first.")
		return

	var new_script = load("res://scripts/simple_boss.gd")
	if not new_script:
		print("ERROR: simple_boss.gd not found!")
		return

	boss.set_script(new_script)
	print("Boss script changed to simple_boss.gd")
	print("Boss will now:")
	print("  - Move back and forth (patrol)")
	print("  - Flash red when hit")
	print("  - Die after 5 hits")
	print("  - Harm Zone damages player on contact")
	print(">>> Press Ctrl+S to save! <<<")
