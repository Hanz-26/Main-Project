@tool
extends EditorScript

## Adds 3 mini-bosses throughout the level - one per floor
## Run: Ctrl+Shift+X

func _run():
	print("=== ADDING MINI-BOSSES ===")

	var scene = get_editor_interface().get_edited_scene_root()
	if not scene:
		print("ERROR: Open game.tscn first!")
		return

	var necro_scene = load("res://scenes/Enemies/Bosses/necromancer.tscn")
	var simple_boss_script = load("res://scripts/simple_boss.gd")

	if not necro_scene:
		print("ERROR: necromancer.tscn not found!")
		return

	# Remove old minibosses if they exist
	var old = scene.get_node_or_null("MiniBosses")
	if old:
		old.free()

	var container = Node2D.new()
	container.name = "MiniBosses"
	scene.add_child(container)
	container.owner = scene

	# =============================================
	# MINI-BOSS 1: Top floor (mid-level guardian)
	# Patrols near the end before the drop
	# Smaller, faster, 3 lives
	# =============================================
	var mb1 = necro_scene.instantiate()
	mb1.name = "MiniBoss_TopFloor"
	mb1.position = Vector2(1600, 120)  # Top floor, x=100 tiles
	if simple_boss_script:
		mb1.set_script(simple_boss_script)
	# Make it smaller than the final boss
	var sprite1 = mb1.get_node_or_null("AnimatedSprite2D")
	if sprite1:
		sprite1.scale = Vector2(2.0, 2.0)  # Smaller than default 3x
		sprite1.modulate = Color(0.6, 1.0, 0.6)  # Green tint
	container.add_child(mb1)
	mb1.owner = scene
	print("  Mini-boss 1 placed on TOP floor (green, fast)")

	# =============================================
	# MINI-BOSS 2: Middle floor (cave guardian)
	# Patrols the middle section
	# Medium size, 4 lives
	# =============================================
	var mb2 = necro_scene.instantiate()
	mb2.name = "MiniBoss_MiddleFloor"
	mb2.position = Vector2(800, 232)  # Middle floor
	if simple_boss_script:
		mb2.set_script(simple_boss_script)
	var sprite2 = mb2.get_node_or_null("AnimatedSprite2D")
	if sprite2:
		sprite2.scale = Vector2(2.5, 2.5)
		sprite2.modulate = Color(1.0, 0.7, 0.3)  # Orange tint
	container.add_child(mb2)
	mb2.owner = scene
	print("  Mini-boss 2 placed on MIDDLE floor (orange)")

	# =============================================
	# MINI-BOSS 3: Bottom floor (biome guardian)
	# Guards the transition between warm and rocky biome
	# Bigger, 4 lives
	# =============================================
	var mb3 = necro_scene.instantiate()
	mb3.name = "MiniBoss_BottomFloor"
	mb3.position = Vector2(1700, 784)  # Bottom floor, between biomes
	if simple_boss_script:
		mb3.set_script(simple_boss_script)
	var sprite3 = mb3.get_node_or_null("AnimatedSprite2D")
	if sprite3:
		sprite3.scale = Vector2(2.8, 2.8)
		sprite3.modulate = Color(0.8, 0.4, 1.0)  # Purple tint
	container.add_child(mb3)
	mb3.owner = scene
	print("  Mini-boss 3 placed on BOTTOM floor (purple)")

	print("")
	print("=== 3 MINI-BOSSES ADDED ===")
	print("  Green  (top floor)    - x=1600, small & fast")
	print("  Orange (middle floor) - x=800, medium")
	print("  Purple (bottom floor) - x=1700, big")
	print("  All have Harm Zones (damage on contact)")
	print("  All die after 5 hits (flash red when hit)")
	print(">>> Press Ctrl+S to save! <<<")
