@tool
extends EditorScript

## Changes all bosses to use quiz_boss.gd instead of simple_boss.gd
## Run: Ctrl+Shift+X

func _run():
	print("=== APPLYING QUIZ BOSS ===")

	var scene = get_editor_interface().get_edited_scene_root()
	if not scene:
		print("ERROR: Open game.tscn first!")
		return

	var quiz_script = load("res://scripts/quiz_boss.gd")
	if not quiz_script:
		print("ERROR: quiz_boss.gd not found!")
		return

	var count = 0

	# Find all boss nodes and swap their script
	# Check BossArea
	var boss_area = scene.get_node_or_null("BossArea")
	if boss_area:
		for child in boss_area.get_children():
			if "ecromancer" in child.name or "Boss" in child.name or "boss" in child.name:
				child.set_script(quiz_script)
				count += 1
				print("  Swapped: ", child.name)

	# Check MiniBosses
	var minibosses = scene.get_node_or_null("MiniBosses")
	if minibosses:
		for child in minibosses.get_children():
			if "Boss" in child.name or "boss" in child.name:
				child.set_script(quiz_script)
				count += 1
				print("  Swapped: ", child.name)

	print("Swapped %d bosses to quiz mode" % count)
	print("")
	print("How it works:")
	print("  1. Player walks near a boss")
	print("  2. Quiz pops up with a math question")
	print("  3. 4 multiple choice answers (A, B, C, D)")
	print("  4. Correct = boss dies!")
	print("  5. Wrong = lose a heart, try again")
	print("  6. Sword does NOT kill bosses - only quiz answers do")
	print("")
	print("Questions: addition, subtraction, multiplication, division")
	print(">>> Press Ctrl+S to save! <<<")
