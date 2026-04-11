extends Node2D

## Simple Boss - Patrols, damages player, can be killed with sword

const SPEED = 40
var direction = -1  # Start moving left
var move_range = 80.0
var start_x = 0.0
var boss_lives = 5

@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	start_x = position.x
	if animated_sprite:
		animated_sprite.play("idle")
		# Position sprite so feet are on the ground
		animated_sprite.position.y = -35

func _process(delta):
	position.x += direction * SPEED * delta

	if position.x > start_x + move_range:
		direction = -1
	elif position.x < start_x - move_range:
		direction = 1

	# Flip sprite to face movement direction
	# The necromancer sprite faces LEFT by default
	# So: moving left = no flip, moving right = flip
	if animated_sprite:
		if direction == -1:
			animated_sprite.flip_h = false  # Facing left (default)
		else:
			animated_sprite.flip_h = true   # Facing right (flipped)

func enemy_take_damage():
	boss_lives -= 1
	print("Boss hit! Lives remaining: ", boss_lives)

	if animated_sprite:
		animated_sprite.modulate = Color(1, 0.3, 0.3)
		await get_tree().create_timer(0.2).timeout
		animated_sprite.modulate = Color(1, 1, 1)

	if boss_lives <= 0:
		print("BOSS DEFEATED!")
		if animated_sprite:
			animated_sprite.modulate = Color(1, 0, 0)
		await get_tree().create_timer(0.5).timeout
		queue_free()
