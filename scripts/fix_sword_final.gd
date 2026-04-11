@tool
extends EditorScript

## FINAL sword position fix
## Run: Ctrl+Shift+X

func _run():
	print("=== FIXING SWORD FINAL ===")

	var player_scene = load("res://scenes/player.tscn")
	if not player_scene:
		print("ERROR: Could not load player.tscn")
		return

	var player = player_scene.instantiate()

	# STATIC SWORD on back - lower, visible, proper size
	var sword = player.get_node_or_null("sword")
	if sword:
		sword.position = Vector2(-5, -5)  # Lower - at waist/back level
		sword.scale = Vector2(0.5, 0.5)
		sword.flip_v = true
		sword.rotation = 0
		sword.region_enabled = true
		sword.region_rect = Rect2(8, 0, 16, 32)
		sword.visible = true
		print("  Static sword: on back, lower, visible")

	# ATTACK ANIMATIONS - lower and further from face
	var sword_attacks = player.get_node_or_null("sword_attacks")
	if sword_attacks:
		sword_attacks.position = Vector2(22, -5)  # Lower (was -12), further right (was 16)
		sword_attacks.rotation = 1.5707964  # 90 degrees horizontal
		sword_attacks.scale = Vector2(0.97, 0.97)
		sword_attacks.visible = false
		print("  Attacks: lower, further from face")

	# SAVE
	var packed = PackedScene.new()
	packed.pack(player)
	var err = ResourceSaver.save(packed, "res://scenes/player.tscn")
	if err == OK:
		print("SUCCESS!")
	else:
		print("ERROR: ", err)
	player.queue_free()
