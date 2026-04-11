@tool
extends EditorScript

## FIX SWORD COMBAT - Makes Q/E actually kill enemies
## Uses Hansel's exact approach:
## - flip_v for left-facing (not rotation)
## - Signal connections for area_entered
## - Default collision layers (layer 1) for detection
## Run: Ctrl+Shift+X

func _run():
	print("=== FIXING SWORD COMBAT ===")

	var player_scene = load("res://scenes/player.tscn")
	if not player_scene:
		print("ERROR: player.tscn not found")
		return

	var player = player_scene.instantiate()

	var sword_attacks = player.get_node_or_null("sword_attacks")
	if not sword_attacks:
		print("ERROR: No sword_attacks node!")
		player.queue_free()
		return

	# Fix sword_attacks - use Hansel's exact approach
	# Position to the RIGHT side, rotation 90deg
	sword_attacks.position = Vector2(19.7, -5)
	sword_attacks.rotation = 1.5707964  # 90 degrees
	sword_attacks.scale = Vector2(0.97, 0.97)
	sword_attacks.visible = false

	# Fix stab_area - default collision layers + weapon_hitzone script
	var stab_area = player.get_node_or_null("sword_attacks/stab_area")
	var weapon_script = load("res://scripts/weapon_hitzone.gd")

	if stab_area:
		# Use DEFAULT collision layers (layer 1, mask 1) like Hansel
		stab_area.collision_layer = 1
		stab_area.collision_mask = 1
		if weapon_script:
			stab_area.set_script(weapon_script)
		print("  stab_area: layer=1, mask=1, weapon_hitzone.gd attached")

	# Fix swing_area
	var swing_area = player.get_node_or_null("sword_attacks/swing_area")
	if swing_area:
		swing_area.collision_layer = 1
		swing_area.collision_mask = 1
		swing_area.position = Vector2(-6.5, -0.5)  # Hansel's offset
		if weapon_script:
			swing_area.set_script(weapon_script)
		print("  swing_area: layer=1, mask=1, weapon_hitzone.gd attached")

	# Fix stab_collision
	var stab_col = player.get_node_or_null("sword_attacks/stab_area/stab_collision")
	if stab_col:
		stab_col.disabled = true  # Disabled until attack
		stab_col.position = Vector2(0, 0)

	# Fix swing_collision
	var swing_col = player.get_node_or_null("sword_attacks/swing_area/swing_collision")
	if swing_col:
		swing_col.disabled = true
		swing_col.position = Vector2(0, 0)

	# SAVE the scene
	var packed = PackedScene.new()
	packed.pack(player)
	var err = ResourceSaver.save(packed, "res://scenes/player.tscn")

	if err == OK:
		print("Player scene saved!")
	else:
		print("ERROR saving: ", err)

	player.queue_free()

	# Now fix the slime scene - add harm_zone on layer 1
	fix_slime()

	print("")
	print("=== COMBAT FIX COMPLETE ===")
	print("How it works (same as Hansel):")
	print("  1. Press Q or E -> sword attack animation plays")
	print("  2. stab_collision/swing_collision ENABLED during attack")
	print("  3. If collision overlaps enemy's Harm Zone Area2D:")
	print("     -> weapon_hitzone.gd _on_area_entered fires")
	print("     -> enemy.queue_free() = enemy dies")
	print("  4. Animation finishes -> collisions disabled again")

func fix_slime():
	print("Fixing slime harm zone...")
	var slime_scene = load("res://scenes/slime.tscn")
	if not slime_scene:
		print("  ERROR: slime.tscn not found")
		return

	var slime = slime_scene.instantiate()

	# Check if HarmZone already exists
	var existing_hz = slime.get_node_or_null("HarmZone")
	if existing_hz:
		# Fix its collision layer to match
		existing_hz.collision_layer = 1  # Default layer so sword can detect it
		existing_hz.collision_mask = 2   # Detect player
		print("  Existing HarmZone fixed: layer=1, mask=2")
	else:
		# Add a new HarmZone
		var harm_zone = Area2D.new()
		harm_zone.name = "HarmZone"
		harm_zone.collision_layer = 1  # Detectable by sword
		harm_zone.collision_mask = 2   # Detects player

		var harm_script = load("res://scripts/harm_zone.gd")
		if harm_script:
			harm_zone.set_script(harm_script)

		slime.add_child(harm_zone)
		harm_zone.owner = slime

		var shape = CollisionShape2D.new()
		var rect = RectangleShape2D.new()
		rect.size = Vector2(12, 16)
		shape.shape = rect
		shape.position = Vector2(0, -7)
		harm_zone.add_child(shape)
		shape.owner = slime

		print("  HarmZone added: layer=1, mask=2")

	var packed = PackedScene.new()
	packed.pack(slime)
	ResourceSaver.save(packed, "res://scenes/slime.tscn")
	slime.queue_free()
