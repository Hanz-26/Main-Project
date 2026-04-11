@tool
extends EditorScript

## Fix sword position and attack height
## Run: Ctrl+Shift+X

func _run():
	print("=== FIXING SWORD ===")

	var player_scene = load("res://scenes/player.tscn")
	if not player_scene:
		print("ERROR: Could not load player.tscn")
		return

	var player = player_scene.instantiate()

	# FIX STATIC SWORD - on character's back, vertical, using region
	var sword = player.get_node_or_null("sword")
	if sword:
		sword.position = Vector2(-5, -12)  # On the back, at body height
		sword.scale = Vector2(0.41, 0.41)
		sword.flip_v = true
		sword.rotation = 0
		# Show only one sword frame (not the whole spritesheet)
		sword.region_enabled = true
		sword.region_rect = Rect2(8, 0, 16, 32)
		print("  Static sword: vertical on back, region cropped")

	# FIX SWORD ATTACKS - at body level, not floating above
	var sword_attacks = player.get_node_or_null("sword_attacks")
	if sword_attacks:
		sword_attacks.position = Vector2(16, -12)  # Same Y as character body
		sword_attacks.rotation = 1.5707964  # 90 degrees
		sword_attacks.scale = Vector2(0.97, 0.97)
		sword_attacks.visible = false  # Hidden until attack
		print("  Sword attacks: at body level, horizontal")

	# SAVE
	var packed = PackedScene.new()
	packed.pack(player)
	var err = ResourceSaver.save(packed, "res://scenes/player.tscn")
	if err == OK:
		print("SUCCESS!")
	else:
		print("ERROR: ", err)
	player.queue_free()
