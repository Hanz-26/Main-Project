@tool
extends EditorScript

## Adds a Harm Zone (collision layer 4) to the slime scene
## so the player's sword can detect and kill slimes
## Run: Ctrl+Shift+X

func _run():
	print("=== FIXING SLIME HITBOX ===")

	var slime_scene = load("res://scenes/slime.tscn")
	if not slime_scene:
		print("ERROR: slime.tscn not found!")
		return

	var slime = slime_scene.instantiate()

	# Check if harm zone already exists
	if slime.get_node_or_null("HarmZone"):
		print("HarmZone already exists on slime")
		slime.queue_free()
		return

	# Add a Harm Zone Area2D on collision layer 4
	# This is what the sword's weapon hitzone detects
	var harm_zone = Area2D.new()
	harm_zone.name = "HarmZone"
	harm_zone.collision_layer = 4  # Layer 4 = detectable by sword
	harm_zone.collision_mask = 0   # Doesn't detect anything itself

	# Also make it damage the player (collision mask 2)
	var harm_script = load("res://scripts/harm_zone.gd")
	if harm_script:
		harm_zone.set_script(harm_script)
	harm_zone.collision_mask = 2  # Also detect player for damage

	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(12, 16)
	shape.shape = rect
	shape.position = Vector2(0, -7)
	harm_zone.add_child(shape)
	shape.owner = slime

	slime.add_child(harm_zone)
	harm_zone.owner = slime

	# Save the modified slime scene
	var packed = PackedScene.new()
	packed.pack(slime)
	var err = ResourceSaver.save(packed, "res://scenes/slime.tscn")
	if err == OK:
		print("SUCCESS: Slime now has HarmZone on layer 4")
		print("  - Sword can detect and kill slimes")
		print("  - HarmZone also damages player on contact")
	else:
		print("ERROR saving: ", err)

	slime.queue_free()
