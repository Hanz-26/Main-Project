extends Node2D

const DRAGON_FIREBALL = preload("uid://51vv1834cadg")
const GHOST = preload("uid://dfvh3dduns6ns")

var final_boss_lives = 7# 2 phases, 3 lives each, plus one final trick phase
@onready var player: CharacterBody2D = $"../../../Player"
@onready var finalboss_room_platforms: Node2D = $"../../../Platforms/Floor_6/final_boss_room"
@onready var finalboss_room_spawns: Node2D = $"../../../Spawn_locations/enemy_spawns/finalboss_room"
@onready var finalboss_room_label: RichTextLabel = $"../../../Labels/NPCs/finalboss_room"
@onready var finalboss_enemies: Node2D = $"../../Final_boss_enemies"
@onready var game_manager: Node = %"Game Manager"

var door_is_closed = false# this variable checks whether player has entered boss area



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#Code below triggers when player enters area
func _on_area_2d_body_entered(body: Node2D) -> void:
	if not door_is_closed:
		door_is_closed = true
		finalboss_room_platforms.get_node("final_boss_gate/AnimationPlayer").play("close_gate")
		player.get_node("Camera2D").enabled = false
		player.get_node("Boss_Camera2D").enabled = true
		#self.get_node("Timer").start(5)# Starts fire breath attack
		start_finalboss_wave(0)

#This functions handles selecting correct phase and wave
func start_finalboss_wave(i):
	if i < 3:
		spawn_phase_1_enemies()
	elif i < 6:
		pass
		spawn_phase_2_enemies()
	match i:
		0:# Phase 1 wave 1
			assign_1x1_enemies()
		1:# Phase 1 wave 2
			pass
			assign_1x2_enemies()
		2:# Phase 1 wave 3
			pass
			assign_1x3_enemies()
		3:# Phase 2 wave 1
			pass
			assign_2x1_enemies()
		4:# Phase 2 wave 2
			pass
			assign_2x2_enemies()
		5:# Phase 2 wave 3
			pass
			assign_2x3_enemies()
		6:# Phase 3
			pass
			#assign_1x1_enemies()

#This function handles spawning enemies for phase 1 waves
func spawn_phase_1_enemies():
	var phase_1_enemies = finalboss_enemies.get_node("phase_1")
	for n in finalboss_room_platforms.get_node("ghost_boundaries/interior").get_children():
		n.set_deferred("disabled", false)
	var spawn_locations = [
		finalboss_room_spawns.get_node("top_right").global_position,
		finalboss_room_spawns.get_node("bottom_left").global_position,
		finalboss_room_spawns.get_node("center").global_position
	]
	for i in range(3):
		var ghost = GHOST.instantiate()
		phase_1_enemies.add_child(ghost)
		ghost.global_position = spawn_locations[i]
		match i:
			0:
				ghost.direction.x = -1
			2:
				ghost.direction.y = 0

#This function handles spawning enemies for phase 2 waves
func spawn_phase_2_enemies():
	var phase_2_enemies = finalboss_enemies.get_node("phase_2")
	for n in finalboss_room_platforms.get_node("ghost_boundaries/interior").get_children():
		n.set_deferred("disabled", true)
	var spawn_locations = [
		finalboss_room_spawns.get_node("top_right").global_position,
		finalboss_room_spawns.get_node("bottom_left").global_position,
		finalboss_room_spawns.get_node("middle_right").global_position,
		finalboss_room_spawns.get_node("middle_left").global_position
	]
	
	for i in range(4):
		var ghost = GHOST.instantiate()
		phase_2_enemies.add_child(ghost)
		ghost.global_position = spawn_locations[i]
		match i:
			0:
				ghost.direction = Vector2(-1, 0.5)
			1:
				ghost.direction = Vector2(1, -0.5)
			2:
				ghost.direction = Vector2(-1, 0)
			3:
				ghost.direction = Vector2(1, 0)

func assign_1x1_enemies():
	var enemies = finalboss_enemies.get_node("phase_1")
	
	finalboss_room_label.text = "This sure is an [b]ODD[/b] guardian"
	enemies.get_child(randi_range(0,2)).get_node("AnimatedSprite2D/Label").text = str(randi_range(0, 49) * 2 + 1)# makes one random ghost odd
	
	for n in enemies.get_children():# makes the rest of the ghosts even
		if not n.get_node("AnimatedSprite2D/Label").text:
			n.get_node("AnimatedSprite2D/Label").text =  str(randi_range(0, 49) * 2)

func assign_1x2_enemies():
	var enemies = finalboss_enemies.get_node("phase_1")
	
	finalboss_room_label.text = "What a [b]SQUARE[/b] looking dragon"
	enemies.get_child(randi_range(0,2)).get_node("AnimatedSprite2D/Label").text = str(randi_range(0, 10) ** 2)# makes one random ghost a square
	for n in enemies.get_children():# makes the rest of the ghosts not squares
		if not n.get_node("AnimatedSprite2D/Label").text:
			var num = randi_range(2, 99)
			while sqrt(num) == round(sqrt(num)):# Checks the random number is not a square
				num = randi_range(2, 99)
			n.get_node("AnimatedSprite2D/Label").text = str(num)

func assign_1x3_enemies():
	var enemies = finalboss_enemies.get_node("phase_1")
	var prime_numbers = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97]
	
	finalboss_room_label.text = "Dragon steak must be pretty [b]PRIME[/b]"
	enemies.get_child(randi_range(0,2)).get_node("AnimatedSprite2D/Label").text = str(prime_numbers[randi_range(0, prime_numbers.size() - 1)])# makes one random ghost a prime number
	for n in enemies.get_children():# makes the rest of the ghosts not squares
		if not n.get_node("AnimatedSprite2D/Label").text:
			var num = randi_range(1, 99)
			while num in prime_numbers:# Checks the random number is not a square
				num = randi_range(1, 99)
			n.get_node("AnimatedSprite2D/Label").text = str(num)

func assign_2x1_enemies():
	var enemies = finalboss_enemies.get_node("phase_2")
	var num = str(randi_range(1, 9))
	
	finalboss_room_label.text = "And the cycle [b]REPEATS[/b]"
	enemies.get_child(randi_range(0,3)).get_node("AnimatedSprite2D/Label").text = str(num + num)# makes one random ghost a repeating number
	for n in enemies.get_children():# makes the rest of the ghosts not repeating
		if not n.get_node("AnimatedSprite2D/Label").text:
			num = randi_range(1, 98)
			while num % 11 == 0:
				num = randi_range(1, 98)
			n.get_node("AnimatedSprite2D/Label").text = str(num)

func assign_2x2_enemies():
	var enemies = finalboss_enemies.get_node("phase_2")
	
	finalboss_room_label.text = "This dragon is [b]ABSOLUTELY[/b] furious"
	enemies.get_child(randi_range(0,3)).get_node("AnimatedSprite2D/Label").text = str(randi_range(0, 99))# makes one random ghost a positive
	for n in enemies.get_children():# makes the rest of the ghosts negative
		if not n.get_node("AnimatedSprite2D/Label").text:
			n.get_node("AnimatedSprite2D/Label").text = str(randi_range(-99, -1))

func assign_2x3_enemies():
	var enemies = finalboss_enemies.get_node("phase_2")
	var con_list = ["φ", "ζ", "δ"]
	finalboss_room_label.text = "This fight is as easy as [b]PIE[/b]"
	enemies.get_child(randi_range(0,3)).get_node("AnimatedSprite2D/Label").text = "π"# makes one random ghost pi
	for n in enemies.get_children():# makes the rest of the ghosts other constants
		if not n.get_node("AnimatedSprite2D/Label").text:
			n.get_node("AnimatedSprite2D/Label").text = con_list.pop_at(randi_range(0, con_list.size() - 1))

func _on_phase_1_child_exiting_tree(node: Node) -> void:
	var num = int(node.get_node("AnimatedSprite2D/Label").text)
	match final_boss_lives:
		7:# wave 1: odd number
			if num % 2 == 1:
				dragon_vulnerable()
			elif final_boss_lives == 7 and game_manager.lives >= 0:
				game_manager.take_damage()
				player.apply_knockback(node.global_position)
		6:# wave 2: square number
			if sqrt(num) == round(sqrt(num)):
				dragon_vulnerable()
			elif final_boss_lives == 6 and game_manager.lives >= 0:
				game_manager.take_damage()
				player.apply_knockback(node.global_position)
		5:# wave 3: prime number
			print(3)









#This code runs when the correct ghost is killed
func dragon_vulnerable():
	print("dragon weak")
	self.get_node("AnimatedSprite2D/Harm Zone").collision_layer = 1# makes boss vulnerable
	self.get_node("AnimatedSprite2D").play("vulnerable")
	self.get_node("AnimatedSprite2D/Harm Zone/CollisionShape2D").position.x += 6# moves it to the right for the animation

func enemy_take_damage():
	print("Dragon hurt")
	final_boss_lives -= 1
	get_node("AnimatedSprite2D/Harm Zone").collision_layer = 4# makes boss invulnerable
	self.get_node("AnimatedSprite2D").play("idle")
	self.get_node("AnimatedSprite2D/Harm Zone/CollisionShape2D").position.x -= 6# moves it back left
	
	for n in finalboss_enemies.get_children():# This kills the remaining ghosts, if any
		if n.get_child_count() > 0:
			for c in n.get_children():
				c.queue_free()
	
	start_finalboss_wave(7 - final_boss_lives)






#This timer is for the dragon fire breath every 10 seconds, first one is 5 seconds
func _on_timer_timeout() -> void:
	self.get_node("Timer").start(10)
	var player_y = player.global_position.y
	var dragon_y = self.get_node("AnimatedSprite2D").global_position.y + 23.043# dragon mouth y coordinate
	var y_delta = -(dragon_y - player_y) / 6.0# y coordinate increment for each fireball after first
	#var slope = (self.get_node("AnimatedSprite2D").global_position.y + 23.043 - player.global_position.y) / (self.get_node("AnimatedSprite2D").global_position.x + 69.352 - player.global_position.x)
	# I was hoping to use the slope to calculate a smoother path between the fireballs and the playerdd
	activate_fire_breath(y_delta)

#This code starts dragon fire breath attack
func activate_fire_breath(y_delta = 0, fireballs_left = 7):
	if fireballs_left == 0:
		return
	var fireball = DRAGON_FIREBALL.instantiate()
	self.get_node("fire_breath").add_child(fireball)
	if fireballs_left == 7:# this number needs to match the initial number of fireballs
		fireball.global_position = self.get_node("AnimatedSprite2D").global_position + Vector2(69.352, 23.043)# first fireball goes in front of dragon's mouth
		fireball.get_node("AnimatedSprite2D").pause()# pauses initial fireball so is in sync with the rest
		await get_tree().create_timer(1.9).timeout	# makes initial fireball lag longer as heads up for player
		fireball.get_node("AnimatedSprite2D").play()# resumes initial fireball so is in sync with the rest
	else:
		fireball.global_position = self.get_node("fire_breath").get_child(self.get_node("fire_breath").get_child_count() - 2).global_position + Vector2(25, y_delta)
	await get_tree().create_timer(0.1).timeout	
	activate_fire_breath(y_delta, fireballs_left - 1)
