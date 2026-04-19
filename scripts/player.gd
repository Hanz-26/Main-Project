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
var _hit_this_attack = []  # track already-hit enemies per attack

func _ready():
	game_manager = get_tree().current_scene.get_node_or_null("GameManager")
	if not game_manager:
		game_manager = get_tree().current_scene.get_node_or_null("Game Manager")

	if sword_attacks and not sword_attacks.animation_finished.is_connected(_on_sword_attacks_animation_finished):
		sword_attacks.animation_finished.connect(_on_sword_attacks_animation_finished)

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

			var facing_left = animated_sprite.flip_h
			# sword_attacks is rotated 90°: flip_v = world left/right mirror, flip_h = world up/down mirror
			sword_attacks.flip_v = facing_left
			sword_attacks.position.x = -19.707367 if facing_left else 19.707367

			if Input.is_action_just_pressed("stab"):
				stab_collision.disabled = false
				if swing_collision:
					swing_collision.disabled = true
				sword_attacks.flip_h = true  # stab sprite is upside down in world space, correct it
				sword_attacks.play("stab")
			elif Input.is_action_just_pressed("swing"):
				if swing_collision:
					swing_collision.disabled = false
				stab_collision.disabled = true
				sword_attacks.flip_h = false
				sword_attacks.play("swing")

	if is_attacking:
		_poll_sword_hits()

	move_and_slide()

func _poll_sword_hits() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	print("DEBUG sword poll - enemies in group: ", enemies.size(), " | sword pos: ", sword_attacks.global_position)
	for enemy in enemies:
		if not is_instance_valid(enemy) or enemy in _hit_this_attack:
			continue
		var dist = enemy.global_position.distance_to(sword_attacks.global_position)
		print("DEBUG enemy: ", enemy.name, " dist: ", dist)
		if dist < 60.0:
			_hit_this_attack.append(enemy)
			print("Sword hit: ", enemy.name)
			if enemy.has_method("enemy_take_damage"):
				enemy.enemy_take_damage()
			else:
				enemy.queue_free()

# Signal: attack animation finished - reset everything
func _on_sword_attacks_animation_finished() -> void:
	if sword:
		sword.visible = true
	if sword_attacks:
		sword_attacks.visible = false
		sword_attacks.flip_h = false
		sword_attacks.flip_v = false
		sword_attacks.position.x = 19.707367  # reset sword to right side
	if swing_collision:
		swing_collision.disabled = true
	if stab_collision:
		stab_collision.disabled = true
	_hit_this_attack.clear()
	is_attacking = false

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
