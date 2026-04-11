@tool
extends EditorScript

## Adds visual checkpoint flags at key locations
## Run: Ctrl+Shift+X

func _run():
	print("=== ADDING CHECKPOINT FLAGS ===")

	var scene = get_editor_interface().get_edited_scene_root()
	if not scene:
		print("ERROR: Open game.tscn first!")
		return

	var flag_script = load("res://scripts/checkpoint_visual.gd")
	if not flag_script:
		print("ERROR: checkpoint_visual.gd not found!")
		return

	# Remove old flags
	var old = scene.get_node_or_null("CheckpointFlags")
	if old:
		old.free()

	var container = Node2D.new()
	container.name = "CheckpointFlags"
	scene.add_child(container)
	container.owner = scene

	var flag_positions = [
		# TOP FLOOR
		["Flag_Start", Vector2(50, 120)],
		["Flag_TopMid", Vector2(800, 120)],
		["Flag_BeforeDrop", Vector2(2350, 120)],

		# MIDDLE FLOOR
		["Flag_MidLanding", Vector2(2350, 232)],
		["Flag_MidCenter", Vector2(1200, 232)],
		["Flag_MidLeft", Vector2(200, 232)],

		# BOTTOM FLOOR
		["Flag_BotStart", Vector2(-150, 792)],
		["Flag_BotGreen", Vector2(400, 792)],
		["Flag_BotWarm", Vector2(1200, 792)],
		["Flag_BotRocky", Vector2(1800, 792)],
		["Flag_BeforeBoss", Vector2(2300, 792)],
	]

	for data in flag_positions:
		var flag = Node2D.new()
		flag.name = data[0]
		flag.position = data[1]
		flag.set_script(flag_script)
		container.add_child(flag)
		flag.owner = scene

	print("Added 11 checkpoint flags:")
	print("  Top floor: Start, Middle, Before Drop")
	print("  Middle floor: Landing, Center, Left")
	print("  Bottom floor: Start, Green, Warm, Rocky, Before Boss")
	print("")
	print("Red flag = not activated yet")
	print("Green flag = checkpoint saved!")
	print(">>> Press Ctrl+S to save! <<<")
