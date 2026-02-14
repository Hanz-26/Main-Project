extends CharacterBody2D


const SPEED = 130.0
const JUMP_VELOCITY = -300.0
var is_attacking = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sword: Sprite2D = $sword
@onready var sword_attacks: AnimatedSprite2D = $sword_attacks
@onready var stab_collision: CollisionShape2D = $sword_attacks/stab_area/stab_collision
@onready var swing_collision: CollisionShape2D = $sword_attacks/swing_area/swing_collision
@onready var game_manager: Node = %"Game Manager"


func _physics_process(delta: float) -> void:
		# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	
	if direction > 0:
		animated_sprite.flip_h = false
		sword.offset = Vector2(0,0)
	elif direction < 0:
		animated_sprite.flip_h = true
		sword.offset = Vector2(28.25,0)
	
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
		
	#Weapon attacks
	if Input.is_action_just_pressed("stab") or Input.is_action_just_pressed("swing"):
		if is_attacking or game_manager.hearts <= 0: #prevent attack spamming or attacking while dead which crashes game
			return
			
		is_attacking = true
		if Input.is_action_just_pressed("stab"):
			sword.visible = false
			sword_attacks.visible = true
			stab_collision.disabled = false
			if animated_sprite.flip_h == true:
				sword_attacks.flip_v = true
				sword_attacks.offset = Vector2(0,35)
				stab_collision.position = Vector2(0,35)
			sword_attacks.play("stab")

		if Input.is_action_just_pressed("swing"):
			sword.visible = false
			sword_attacks.visible = true
			swing_collision.disabled = false
			if animated_sprite.flip_h == true:
				sword_attacks.flip_v = true
				sword_attacks.offset = Vector2(0,35)
				swing_collision.position = Vector2(0,35)
			sword_attacks.play("swing")
			
	move_and_slide()

#this function receives a signal when the attack animation is over
func _on_sword_attacks_animation_finished() -> void:
	sword.visible = true
	sword_attacks.visible = false
	sword_attacks.flip_v = false
	swing_collision.disabled = true
	stab_collision.disabled = true
	sword_attacks.offset = Vector2(0,0) #reset attack animation to right side
	swing_collision.position = Vector2(0,0) #reset swing collition to right side
	stab_collision.position = Vector2(0,0) #reset stab collition to right side
	is_attacking =  false


#NEED TO FINISH KNOCKBACK FUNCTION
func apply_knockback():
	pass
	'''
	var knockback = Vector2.ZERO
	var knockback_timer = 0
	
	#direction, force, duration
	knockback = Vector2(10, 10) * 150
	knockback_timer = 100.12
	
	if knockback_timer > 0:
		velocity = knockback
		knockback_timer -= .00010
		if knockback_timer <= 0:
			knockback = Vector2.ZERO
	else:
		pass#_movement(1)
	move_and_slide()
'''
