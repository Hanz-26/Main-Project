extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -300.0
var is_attacking = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sword = get_node_or_null("sword")
@onready var sword_attacks = get_node_or_null("sword_attacks")
@onready var stab_collision = get_node_or_null("sword_attacks/stab_area/stab_collision")
@onready var swing_collision = get_node_or_null("sword_attacks/swing_area/swing_collision")

var game_manager = null

func _ready():
	game_manager = get_tree().current_scene.get_node_or_null("GameManager")
	if not game_manager:
		game_manager = get_tree().current_scene.get_node_or_null("Game Manager")

	# Connect animation_finished signal
	if sword_attacks and not sword_attacks.animation_finished.is_connected(_on_sword_attacks_animation_finished):
		sword_attacks.animation_finished.connect(_on_sword_attacks_animation_finished)

	# Connect area_entered signals so sword kills enemies
	var stab_area = get_node_or_null("sword_attacks/stab_area")
	if stab_area and not stab_area.area_entered.is_connected(_on_weapon_area_entered):
		stab_area.area_entered.connect(_on_weapon_area_entered)
		print("Stab area_entered connected")

	var swing_area = get_node_or_null("sword_attacks/swing_area")
	if swing_area and not swing_area.area_entered.is_connected(_on_weapon_area_entered):
		swing_area.area_entered.connect(_on_weapon_area_entered)
		print("Swing area_entered connected")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("move_left", "move_right")

	if direction > 0:
		animated_sprite.flip_h = false
		if sword:
			sword.offset = Vector2(0, 0)
	elif direction < 0:
		animated_sprite.flip_h = true
		if sword:
			sword.offset = Vector2(28.25, 0)

	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
	else:
		animated_sprite.play("jump")

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Weapon attacks - EXACT same logic as Hansel's player.gd
	if Input.is_action_just_pressed("stab") or Input.is_action_just_pressed("swing"):
		if not sword_attacks or not stab_collision:
			pass  # No sword nodes yet
		elif is_attacking:
			pass  # Already attacking
		elif game_manager and game_manager.hearts <= 0:
			pass  # Dead
		else:
			is_attacking = true
			if sword:
				sword.visible = false
			sword_attacks.visible = true
			stab_collision.disabled = false
			if swing_collision:
				swing_collision.disabled = false

			# Hansel's approach: flip_v + offset for left-facing
			if animated_sprite.flip_h == true:
				sword_attacks.flip_v = true
				sword_attacks.offset = Vector2(0, 35)
				stab_collision.position = Vector2(0, 35)

			if Input.is_action_just_pressed("stab"):
				sword_attacks.play("stab")
			if Input.is_action_just_pressed("swing"):
				sword_attacks.play("swing")

	move_and_slide()

# Signal: attack animation finished - reset everything
func _on_sword_attacks_animation_finished() -> void:
	if sword:
		sword.visible = true
	if sword_attacks:
		sword_attacks.visible = false
		sword_attacks.flip_v = false
		sword_attacks.offset = Vector2(0, 0)
	if swing_collision:
		swing_collision.disabled = true
		swing_collision.position = Vector2(0, 0)
	if stab_collision:
		stab_collision.disabled = true
		stab_collision.position = Vector2(0, 0)
	is_attacking = false

func _on_weapon_area_entered(area: Area2D) -> void:
	# Sword hit an enemy's area - kill it!
	var enemy = area.get_parent()
	if enemy == self or enemy == sword_attacks:
		return  # Don't hit ourselves
	# Walk up the tree to find the enemy root
	if not enemy.has_method("enemy_take_damage") and not (enemy is Node2D):
		enemy = enemy.get_parent()
	if enemy:
		print("Sword hit: ", enemy.name)
		if enemy.has_method("enemy_take_damage"):
			enemy.enemy_take_damage()
		elif enemy.name != "Player" and enemy != self:
			enemy.queue_free()

func apply_knockback(hit_position: Vector2):
	var dir = (global_position - hit_position).normalized()
	var force = 500
	var timer = 0.15
	var knockback_velocity = dir * force
	knockback_velocity.y = -100
	while timer > 0:
		velocity = knockback_velocity
		move_and_slide()
		await get_tree().physics_frame
		timer -= get_physics_process_delta_time()
