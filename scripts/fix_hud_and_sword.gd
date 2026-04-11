@tool
extends EditorScript

## FIX HUD AND SWORD ANIMATIONS
## - Hearts: use single heart.png, 3 full hearts, dim when lost
## - Sword attacks: positioned to the SIDE of character, horizontal

func _run():
	print("=== FIXING HUD AND SWORD ===")

	var player_scene = load("res://scenes/player.tscn")
	if not player_scene:
		print("ERROR: Could not load player.tscn")
		return

	var player = player_scene.instantiate()

	fix_hearts(player)
	fix_sword(player)

	var packed = PackedScene.new()
	packed.pack(player)
	var err = ResourceSaver.save(packed, "res://scenes/player.tscn")
	if err == OK:
		print("SUCCESS: Player scene saved!")
	else:
		print("ERROR saving: ", err)
	player.queue_free()

func fix_hearts(player):
	print("Fixing hearts...")
	var hearts_node = player.get_node_or_null("UI/Health/Hearts")
	if not hearts_node:
		print("  No Hearts node found")
		return

	# Load the single heart texture
	var heart_tex = load("res://assets/sprites/Hearts/basic/heart.png")
	if not heart_tex:
		print("  heart.png not found!")
		return

	# Remove all existing heart children
	for child in hearts_node.get_children():
		child.queue_free()

	# Wait for queue_free to process
	# Since we're in tool mode, we need to remove them directly
	while hearts_node.get_child_count() > 0:
		var child = hearts_node.get_child(0)
		hearts_node.remove_child(child)
		child.free()

	# Create 3 full hearts and 3 empty hearts
	# Full hearts: bright red (visible by default)
	# Empty hearts: dark/transparent (hidden by default)
	for i in range(3):
		# Full heart (On)
		var heart_on = Sprite2D.new()
		heart_on.name = "Heart_%d_On" % (i + 1)
		heart_on.texture = heart_tex
		heart_on.position = Vector2(i * 22, 0)
		heart_on.scale = Vector2(1.8, 1.8)
		heart_on.visible = true
		hearts_node.add_child(heart_on)
		heart_on.owner = player

		# Empty heart (Off) - dark version, hidden by default
		var heart_off = Sprite2D.new()
		heart_off.name = "Heart_%d_Off" % (i + 1)
		heart_off.texture = heart_tex
		heart_off.position = Vector2(i * 22, 0)
		heart_off.scale = Vector2(1.8, 1.8)
		heart_off.modulate = Color(0.15, 0.15, 0.15, 0.8)  # Very dark, slightly transparent
		heart_off.visible = false  # Hidden until player takes damage
		hearts_node.add_child(heart_off)
		heart_off.owner = player

	print("  3 hearts created (full=red, empty=dark)")

func fix_sword(player):
	print("Fixing sword attacks...")

	var sword_attacks = player.get_node_or_null("sword_attacks")
	if not sword_attacks:
		print("  No sword_attacks node found")
		return

	# Position the sword attacks to the SIDE of the character (not on top)
	# The character center is at (0, -12), so attacks should be offset to the right
	sword_attacks.position = Vector2(16, -10)  # To the right and at character height

	# Rotate the sword attacks 90 degrees so they display horizontally
	sword_attacks.rotation_degrees = -90  # Rotate to be horizontal

	# Fix stab collision position
	var stab_col = player.get_node_or_null("sword_attacks/stab_area/stab_collision")
	if stab_col:
		stab_col.position = Vector2(0, -10)  # Offset in rotated space

	# Fix swing collision position
	var swing_col = player.get_node_or_null("sword_attacks/swing_area/swing_collision")
	if swing_col:
		swing_col.position = Vector2(0, -10)

	# Fix the static sword sprite position (idle sword next to player)
	var sword = player.get_node_or_null("sword")
	if sword:
		sword.position = Vector2(10, -8)  # Next to character, at waist height
		sword.rotation_degrees = -45  # Slight angle like holding it

	print("  Sword attacks rotated horizontal, positioned to side of character")
