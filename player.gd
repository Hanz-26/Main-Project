extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const ATTACK_RANGE = 36.0
const BOSS_ATTACK_RANGE = 45.0

var _is_attacking: bool = false
var _stomp_cooldown: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound
@onready var stomp_area: Area2D = $StompArea
@onready var sword_group: Node2D = $SwordGroup
@onready var sword_swing_sound: AudioStreamPlayer = $SwordSwingSound
@onready var sword_hit_sound: AudioStreamPlayer = $SwordHitSound
@onready var stomp_sound: AudioStreamPlayer = $StompSound


func _ready() -> void:
	add_to_group("player")


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump_sound.play()

	if Input.is_action_just_pressed("attack") and not _is_attacking:
		_start_attack()

	var direction := Input.get_axis("move_left", "move_right")

	if not _is_attacking:
		if direction > 0:
			animated_sprite.flip_h = false
		elif direction < 0:
			animated_sprite.flip_h = true

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

	move_and_slide()
	_check_stomp()
	_update_sword()


func _start_attack() -> void:
	_is_attacking = true
	sword_group.scale = Vector2(1.0, 1.0)
	sword_swing_sound.play()
	var attack_dir = -1 if animated_sprite.flip_h else 1
	var thrust_pos = Vector2(attack_dir * 14, -10)
	var thrust_rot = attack_dir * PI / 2
	var tween = create_tween().set_parallel(true)
	tween.tween_property(sword_group, "position", thrust_pos, 0.07)
	tween.tween_property(sword_group, "rotation", thrust_rot, 0.07)
	await get_tree().create_timer(0.12).timeout
	if _is_attacking:
		_do_attack_hit()
	await get_tree().create_timer(0.28).timeout
	_is_attacking = false


func _do_attack_hit() -> void:
	var attack_dir = -1 if animated_sprite.flip_h else 1
	var hit_anything = false
	var targets = get_tree().get_nodes_in_group("enemy") + get_tree().get_nodes_in_group("boss")
	for enemy in targets:
		if not is_instance_valid(enemy):
			continue
		var diff = enemy.global_position - global_position
		var range = BOSS_ATTACK_RANGE if enemy.is_in_group("boss") else ATTACK_RANGE
		if abs(diff.x) < range and diff.x * attack_dir >= -5:
			enemy.take_hit()
			hit_anything = true
	if hit_anything:
		sword_hit_sound.play()


func _check_stomp() -> void:
	if velocity.y <= 0 or _stomp_cooldown:
		return
	for area in stomp_area.get_overlapping_areas():
		var enemy = area.get_parent()
		if not enemy.has_method("take_hit"):
			continue
		var shape = area.get_child(0)
		if shape and global_position.y < shape.global_position.y - 2:
			continue
		if enemy.has_method("take_hit"):
			enemy.take_hit()
			velocity.y = -200.0
			stomp_sound.play()
			_stomp_invincibility()
			break


func _stomp_invincibility() -> void:
	_stomp_cooldown = true
	add_to_group("invincible")
	await get_tree().create_timer(0.35).timeout
	if is_inside_tree():
		remove_from_group("invincible")
		_stomp_cooldown = false


func _update_sword() -> void:
	if _is_attacking:
		return
	var side = 1 if animated_sprite.flip_h else -1
	sword_group.position = Vector2(side * 7, -13)
	sword_group.rotation = 0.0
	sword_group.scale = Vector2(0.62, 0.62)
