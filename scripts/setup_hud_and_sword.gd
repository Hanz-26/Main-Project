@tool
extends EditorScript

## Run this script ONCE in the Godot editor:
## 1. Open this file in the Script editor
## 2. Go to File > Run (or Ctrl+Shift+X)
## It will add the HUD (hearts, lives, coins, attack labels) and
## sword attack system to your Player scene.

func _run():
	print("=== Setting up HUD and Sword System ===")

	# Open the player scene
	var player_scene = load("res://scenes/player.tscn")
	if not player_scene:
		print("ERROR: Could not load res://scenes/player.tscn")
		return

	var player = player_scene.instantiate()

	# Check if UI already exists
	if player.has_node("UI"):
		print("UI node already exists. Skipping HUD setup.")
	else:
		setup_hud(player)

	if player.has_node("sword"):
		print("Sword node already exists. Skipping sword setup.")
	else:
		setup_sword(player)

	# Save the modified scene
	var packed = PackedScene.new()
	packed.pack(player)
	var err = ResourceSaver.save(packed, "res://scenes/player.tscn")
	if err == OK:
		print("SUCCESS: Player scene saved with HUD and sword!")
	else:
		print("ERROR: Failed to save player scene. Error code: ", err)

	player.queue_free()
	print("=== Setup Complete ===")

func setup_hud(player: Node):
	print("Adding HUD...")

	# Create UI CanvasLayer (stays on screen, not affected by camera)
	var ui = CanvasLayer.new()
	ui.name = "UI"
	player.add_child(ui)
	ui.owner = player

	# === HEALTH SECTION ===
	var health = Node2D.new()
	health.name = "Health"
	health.position = Vector2(0, 0)
	ui.add_child(health)
	health.owner = player

	# Hearts container
	var hearts = Node2D.new()
	hearts.name = "Hearts"
	hearts.position = Vector2(10, 10)
	health.add_child(hearts)
	hearts.owner = player

	# Load heart texture
	var heart_tex = load("res://assets/sprites/Hearts/animated/border/heart_animated_1.png")
	if not heart_tex:
		heart_tex = load("res://assets/sprites/Hearts/basic/heart.png")
	if not heart_tex:
		print("WARNING: No heart texture found. Using placeholder.")

	# Create 3 pairs of hearts (on/off)
	for i in range(3):
		var heart_on = Sprite2D.new()
		heart_on.name = "Heart_%d_On" % (i + 1)
		heart_on.texture = heart_tex
		heart_on.position = Vector2(i * 20, 0)
		heart_on.scale = Vector2(1.2, 1.2)
		hearts.add_child(heart_on)
		heart_on.owner = player

		var heart_off = Sprite2D.new()
		heart_off.name = "Heart_%d_Off" % (i + 1)
		heart_off.texture = heart_tex
		heart_off.position = Vector2(i * 20, 0)
		heart_off.scale = Vector2(1.2, 1.2)
		heart_off.modulate = Color(0.2, 0.2, 0.2, 0.7) # Dark/dim for empty heart
		heart_off.visible = false
		hearts.add_child(heart_off)
		heart_off.owner = player

	# Lives display
	var lives_node = Node2D.new()
	lives_node.name = "Lives"
	lives_node.position = Vector2(80, 10)
	health.add_child(lives_node)
	lives_node.owner = player

	# Lives icon (small knight sprite)
	var knight_tex = load("res://assets/sprites/Characters/knight.png")
	if knight_tex:
		var life_sprite = Sprite2D.new()
		life_sprite.name = "Life_sprite"
		life_sprite.texture = knight_tex
		life_sprite.hframes = 6
		life_sprite.vframes = 10
		life_sprite.frame = 0
		life_sprite.scale = Vector2(0.8, 0.8)
		lives_node.add_child(life_sprite)
		life_sprite.owner = player

	var lives_label = Label.new()
	lives_label.name = "Lives_count"
	lives_label.text = "x3"
	lives_label.position = Vector2(12, -6)
	var font = load("res://assets/fonts/PixelOperator8-Bold.ttf")
	if font:
		lives_label.add_theme_font_override("font", font)
	lives_label.add_theme_font_size_override("font_size", 8)
	lives_node.add_child(lives_label)
	lives_label.owner = player

	# === COINS SECTION ===
	var coins = Node2D.new()
	coins.name = "Coins"
	coins.position = Vector2(10, 30)
	ui.add_child(coins)
	coins.owner = player

	var coin_tex = load("res://assets/sprites/coin.png")
	if coin_tex:
		var coin_symbol = Sprite2D.new()
		coin_symbol.name = "Coin_symbol"
		coin_symbol.texture = coin_tex
		coin_symbol.hframes = 4
		coin_symbol.scale = Vector2(0.8, 0.8)
		coins.add_child(coin_symbol)
		coin_symbol.owner = player

	var coins_label = Label.new()
	coins_label.name = "Coins_counter"
	coins_label.text = "x0"
	coins_label.position = Vector2(12, -6)
	if font:
		coins_label.add_theme_font_override("font", font)
	coins_label.add_theme_font_size_override("font_size", 8)
	coins.add_child(coins_label)
	coins_label.owner = player

	# === ATTACK LABELS (Q and E) ===
	var attacks = Node2D.new()
	attacks.name = "Attacks"
	attacks.position = Vector2(10, 195)
	ui.add_child(attacks)
	attacks.owner = player

	# Stab label (Q key)
	var stab_letter = Label.new()
	stab_letter.name = "Stab_letter"
	stab_letter.text = "Q"
	stab_letter.position = Vector2(0, 0)
	if font:
		stab_letter.add_theme_font_override("font", font)
	stab_letter.add_theme_font_size_override("font_size", 10)
	attacks.add_child(stab_letter)
	stab_letter.owner = player

	# Swing label (E key)
	var swing_letter = Label.new()
	swing_letter.name = "Swing_letter"
	swing_letter.text = "E"
	swing_letter.position = Vector2(20, 0)
	if font:
		swing_letter.add_theme_font_override("font", font)
	swing_letter.add_theme_font_size_override("font_size", 10)
	attacks.add_child(swing_letter)
	swing_letter.owner = player

	# Sword icon sprites under the Q/E labels
	var sword_tex = load("res://assets/sprites/Weapons/excalibur_.png")
	if sword_tex:
		var stab_icon = Sprite2D.new()
		stab_icon.name = "Stab"
		stab_icon.texture = sword_tex
		stab_icon.hframes = 4
		stab_icon.vframes = 4
		stab_icon.frame = 12  # stab frame
		stab_icon.position = Vector2(5, 18)
		stab_icon.scale = Vector2(0.8, 0.8)
		attacks.add_child(stab_icon)
		stab_icon.owner = player

		var swing_icon = Sprite2D.new()
		swing_icon.name = "Swing"
		swing_icon.texture = sword_tex
		swing_icon.hframes = 4
		swing_icon.vframes = 4
		swing_icon.frame = 4  # swing frame
		swing_icon.position = Vector2(25, 18)
		swing_icon.scale = Vector2(0.8, 0.8)
		attacks.add_child(swing_icon)
		swing_icon.owner = player

	print("HUD added: Hearts (3), Lives counter, Coins counter, Attack labels (Q/E)")

func setup_sword(player: Node):
	print("Adding sword system...")

	var sword_tex = load("res://assets/sprites/Weapons/excalibur_.png")
	if not sword_tex:
		print("WARNING: excalibur_.png not found. Sword sprites won't display.")
		return

	# Static sword sprite (shown when not attacking)
	var sword = Sprite2D.new()
	sword.name = "sword"
	sword.texture = sword_tex
	sword.hframes = 4
	sword.vframes = 4
	sword.frame = 0
	sword.position = Vector2(8, 2)
	sword.scale = Vector2(0.7, 0.7)
	player.add_child(sword)
	sword.owner = player

	# Sword attacks AnimatedSprite2D
	var sword_attacks = AnimatedSprite2D.new()
	sword_attacks.name = "sword_attacks"
	sword_attacks.visible = false
	sword_attacks.position = Vector2(8, 0)

	# Create SpriteFrames with stab and swing animations
	var frames = SpriteFrames.new()

	# Stab animation: row 3 of excalibur_.png (y=96), 4 frames 32x32
	frames.add_animation("stab")
	frames.set_animation_speed("stab", 16.0)
	frames.set_animation_loop("stab", false)
	for i in range(4):
		var atlas = AtlasTexture.new()
		atlas.atlas = sword_tex
		atlas.region = Rect2(i * 32, 96, 32, 32)
		frames.add_frame("stab", atlas)

	# Swing animation: row 1 of excalibur_.png (y=32), 4 frames 32x32
	frames.add_animation("swing")
	frames.set_animation_speed("swing", 12.0)
	frames.set_animation_loop("swing", false)
	for i in range(4):
		var atlas = AtlasTexture.new()
		atlas.atlas = sword_tex
		atlas.region = Rect2(i * 32, 32, 32, 32)
		frames.add_frame("swing", atlas)

	# Remove default animation if it exists
	if frames.has_animation("default"):
		frames.remove_animation("default")

	sword_attacks.sprite_frames = frames
	player.add_child(sword_attacks)
	sword_attacks.owner = player

	# Stab area (Area2D with CollisionShape2D)
	var stab_area = Area2D.new()
	stab_area.name = "stab_area"
	stab_area.collision_layer = 0
	stab_area.collision_mask = 4  # Detect enemy harm zones
	sword_attacks.add_child(stab_area)
	stab_area.owner = player

	# Attach weapon_hitzone script
	var hitzone_script = load("res://scripts/weapon_hitzone.gd")
	if hitzone_script:
		stab_area.set_script(hitzone_script)

	var stab_shape = CollisionShape2D.new()
	stab_shape.name = "stab_collision"
	stab_shape.disabled = true
	var stab_rect = RectangleShape2D.new()
	stab_rect.size = Vector2(20, 10)
	stab_shape.shape = stab_rect
	stab_shape.position = Vector2(10, 0)
	stab_area.add_child(stab_shape)
	stab_shape.owner = player

	# Swing area
	var swing_area = Area2D.new()
	swing_area.name = "swing_area"
	swing_area.collision_layer = 0
	swing_area.collision_mask = 4
	sword_attacks.add_child(swing_area)
	swing_area.owner = player

	if hitzone_script:
		swing_area.set_script(hitzone_script)

	var swing_shape = CollisionShape2D.new()
	swing_shape.name = "swing_collision"
	swing_shape.disabled = true
	var swing_rect = RectangleShape2D.new()
	swing_rect.size = Vector2(24, 14)
	swing_shape.shape = swing_rect
	swing_shape.position = Vector2(10, 0)
	swing_area.add_child(swing_shape)
	swing_shape.owner = player

	print("Sword system added: sword sprite, stab/swing animations, hitzone areas")
