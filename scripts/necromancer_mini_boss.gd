extends Node2D

const SKELETON = preload("uid://ctoi65vmimc3d")
const FLOATING_SKULL = preload("uid://bdc5hf7v6c6pj")

var miniboss_lives = 3
@onready var player: CharacterBody2D = $"../../../Player"
@onready var miniboss_room_platforms: Node2D = $"../../../Platforms/Floor_3/miniboss_room" #node holding platforms in miniboss room
@onready var miniboss_room_spawns: Node2D = $"../../../Spawn_locations/enemy_spawns/miniboss_room" #enemy spawn markers
@onready var miniboss_room_label: Label = $"../../../Labels/NPCs/miniboss_room"
@onready var miniboss_enemies: Node2D = $"../../Miniboss_enemies"
@onready var game_manager: Node = %"Game Manager"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#This runs when the player loses the fight
func reset_boss():
	if is_fight_on:
		print("miniboss reset")
		miniboss_lives = 3
		visible = false
		get_node("AnimatedSprite2D/Harm Zone").collision_layer = 4
		door_is_closed = false
		is_fight_on = false
		miniboss_room_label.visible = false
		miniboss_room_platforms.get_node("miniboss_gate").visible = false
		miniboss_room_platforms.get_node("miniboss_gate/AnimationPlayer").play("RESET")
		for i in range(1, miniboss_room_platforms.get_child_count()):
			miniboss_room_platforms.get_child(i).visible = false
			miniboss_room_platforms.get_child(i).get_node("CollisionShape2D").set_deferred("disabled", true)
		for n in self.get_children():# This kills the skeletons that have spawned
			if n.name != "AnimatedSprite2D":# This avoids killing the animated sprite child of the node
				n.queue_free()
		for n in miniboss_enemies.get_children():# This kills all the floating skulls
			if n.get_child_count() > 0:
				for c in n.get_children():
					c.queue_free()

# This runs when the miniboss is killed
func _exit_tree():
	if miniboss_lives == 0:# miniboss gets killed when changing scenes to main menu
		print("miniboss killed")
		miniboss_room_label.visible = false
		player.get_node("Camera2D").enabled = true
		player.get_node("Boss_Camera2D").enabled = false
		miniboss_room_platforms.get_node("miniboss_gate").visible = false
		miniboss_room_platforms.get_node("miniboss_gate/AnimationPlayer").play("RESET")
	
# code to run when necromancer miniboss is vulnerable
func necromancer_vulnerable():
	print("miniboss is vulnerable")
	get_node("AnimatedSprite2D/Harm Zone").collision_layer = 1
	miniboss_room_platforms.get_node("miniboss_shield").visible = false
	miniboss_room_platforms.get_node("miniboss_shield/CollisionShape2D").set_deferred("disabled", true)
	
# This runs when miniboss takes damage
func enemy_take_damage():
	#print("miniboss lives: ", miniboss_lives)
	miniboss_lives -= 1
	get_node("AnimatedSprite2D/Harm Zone").collision_layer = 4
	for n in self.get_children():# This kills the skeletons that have spawned
		if n.name != "AnimatedSprite2D":# This avoids killing the animated sprite child of the node
			n.queue_free()
	for n in miniboss_enemies.get_children():# This kills the floating skulls
		if n.get_child_count() > 0:
			for c in n.get_children():
				c.queue_free()
	if miniboss_lives > 0:
		#player.apply_knockback(self.global_position)
		player.global_position = miniboss_room_spawns.get_node("floating_skulls_spawns/wave_3/left_spawn").global_position + Vector2(50,0)
		miniboss_room_platforms.get_node("miniboss_shield").visible = true
		miniboss_room_platforms.get_node("miniboss_shield/CollisionShape2D").set_deferred("disabled", false)
		await get_tree().create_timer(1).timeout	
	match miniboss_lives:
		2: spawn_wave_2()
		1: spawn_wave_3()
		0: self.queue_free()

#code to run when player enteres mini-boss area
var door_is_closed = false
func _on_area_2d_body_entered(body: Node2D) -> void:
	if not door_is_closed:
		door_is_closed = true
		print("area entered")
		miniboss_room_platforms.get_node("miniboss_gate").visible = true
		miniboss_room_platforms.get_node("miniboss_gate/AnimationPlayer").play("close")
		player.get_node("Camera2D").enabled = false
		player.get_node("Boss_Camera2D").enabled = true
		for i in range(1, miniboss_room_platforms.get_child_count()):
			miniboss_room_platforms.get_child(i).get_node("CollisionShape2D").set_deferred("disabled", true)

#code to run when player enters miniboss shield area
var is_fight_on = false
func _on_area_2d_body_entered_2(body: Node2D) -> void:
	if (not is_fight_on):
		miniboss_room_label.visible = true
		is_fight_on = true
		print("miniboss activated")
		visible = true
		for i in range(1, miniboss_room_platforms.get_child_count()):
			miniboss_room_platforms.get_child(i).visible = true
			miniboss_room_platforms.get_child(i).get_node("CollisionShape2D").set_deferred("disabled", false)
		spawn_wave_1()#Change if you want to launch any wave first

func spawn_wave_1():
	var wave_1_enemies = miniboss_enemies.get_node("wave_1")
	var float_skull = FLOATING_SKULL.instantiate()
	var enemy = SKELETON.instantiate()
	
	add_child(enemy)
	enemy.global_position = miniboss_room_spawns.get_node("up_spawn").global_position
	
	print("Wave 1 begins")
	miniboss_room_label.text = "Wave 1: x mod 2 = 0"
	
	wave_1_enemies.add_child(float_skull)
	float_skull.global_position = miniboss_room_spawns.get_node("floating_skulls_spawns/wave_1/up_spawn").global_position
	float_skull = FLOATING_SKULL.instantiate()
	float_skull.direction = Vector2(1,0)
	wave_1_enemies.add_child(float_skull)
	float_skull.global_position = miniboss_room_spawns.get_node("floating_skulls_spawns/wave_1/down_spawn").global_position
		
	#Code below makes it so only one the floating skulls has an even number
	wave_1_enemies.get_child(randi_range(0, 1)).get_node("AnimatedSprite2D/Label").text = str(randi_range(0,49) * 2)
	for n in wave_1_enemies.get_children():
		if n.get_node("AnimatedSprite2D/Label").text == "":
			n.get_node("AnimatedSprite2D/Label").text = str(randi_range(0,49) * 2 + 1)

#This function runs when one of the floating skulls on miniboss_enemies/wave_1 is killed
func _on_wave_1_child_exiting_tree(node: Node) -> void:
	if is_fight_on:
		var enemy_num = int(node.get_node("AnimatedSprite2D/Label").text)
		#var wave_1_enemies = miniboss_enemies.get_node("wave_1")
		print("floating skull killed: ", enemy_num)
		if enemy_num % 2 == 0:
			necromancer_vulnerable()
		elif miniboss_lives == 3 and game_manager.lives >= 0:
			game_manager.take_damage()
			player.apply_knockback(node.global_position)

func spawn_wave_2():
	print("Wave 2 begins")
	miniboss_room_label.text = "Wave 2: x mod 5 = 3"
	var wave_2_enemies = miniboss_enemies.get_node("wave_2")
	
	#add skeleton enemies
	var enemy = SKELETON.instantiate()#1
	add_child(enemy)
	enemy.global_position = miniboss_room_spawns.get_node("left_spawn").global_position
	enemy = SKELETON.instantiate()#2
	add_child(enemy)
	enemy.global_position = miniboss_room_spawns.get_node("right_spawn").global_position
	
	#add floating skulls enemies
	for i in range(3):
		var float_skull = FLOATING_SKULL.instantiate()
		wave_2_enemies.add_child(float_skull)
		float_skull.global_position = miniboss_room_spawns.get_node("floating_skulls_spawns/wave_2").get_child(i).global_position
		if i == 2:# This is the bottom spawn point
			float_skull.direction = Vector2(1, 0)# Makes it go right
			float_skull.get_node("AnimatedSprite2D/ray_casts/RayCast2D_right").enabled = true# This should not be necessary ¯\_(ツ)_/¯
	
	#Code below makes it so only one of the skulls has a number x mod 5 = 3
	wave_2_enemies.get_child(randi_range(0,2)).get_node("AnimatedSprite2D/Label").text = str(randi_range(0,19) * 5 + 3)
	for n in wave_2_enemies.get_children():
		if n.get_node("AnimatedSprite2D/Label").text == "":
			var add_num = 3
			while add_num == 3:
				add_num = randi_range(0,4)
			n.get_node("AnimatedSprite2D/Label").text = str(randi_range(0,19) * 5 + add_num)

func _on_wave_2_child_exiting_tree(node: Node) -> void:
	if is_fight_on:
		var enemy_num = int(node.get_node("AnimatedSprite2D/Label").text)
		#var wave_2_enemies = miniboss_enemies.get_node("wave_2")
		print("floating skull killed: ", enemy_num)
		if enemy_num % 5 == 3:
			necromancer_vulnerable()
		elif miniboss_lives == 2 and game_manager.lives >= 0:
			game_manager.take_damage()
			player.apply_knockback(node.global_position)

var wave_3_div = randi_range(3,9)# divisor
var wave_3_rem = randi_range(0, wave_3_div - 1)# remainder
func spawn_wave_3():
	print("Wave 3 begins")
	var wave_3_enemies = miniboss_enemies.get_node("wave_3")
	miniboss_room_label.text = "Wave 3: x mod " + str(wave_3_div) + " = " + str(wave_3_rem)
	
	#add skeleton enemies
	for i in range(3):
		var enemy = SKELETON.instantiate()
		add_child(enemy)
		enemy.global_position = miniboss_room_spawns.get_child(i).global_position
	#add floating skulls enemies
	for i in range(4):
		var float_skull = FLOATING_SKULL.instantiate()
		wave_3_enemies.add_child(float_skull)
		float_skull.global_position = miniboss_room_spawns.get_node("floating_skulls_spawns/wave_3").get_child(i).global_position
		if i > 1:# These are the bottom spawn points
			float_skull.direction = Vector2(1, 0)# Makes it go right
			float_skull.get_node("AnimatedSprite2D/ray_casts/RayCast2D_right").enabled = true# This should not be necessary ¯\_(ツ)_/¯. I think I need to recall _ready() instead
	
	#Code below makes it so only one of the skulls has a number x mod {div} = {rem}
	@warning_ignore("integer_division")
	wave_3_enemies.get_child(randi_range(0,3)).get_node("AnimatedSprite2D/Label").text = str(randi_range(0, 100/wave_3_div - 1) * wave_3_div + wave_3_rem)
	for n in wave_3_enemies.get_children():
		if n.get_node("AnimatedSprite2D/Label").text == "":
			var add_num = wave_3_rem
			while add_num == wave_3_rem:
				add_num = randi_range(0, wave_3_div - 1)
			@warning_ignore("integer_division")
			n.get_node("AnimatedSprite2D/Label").text = str(randi_range(0, 100/wave_3_div - 1) * wave_3_div + add_num)

func _on_wave_3_child_exiting_tree(node: Node) -> void:
	if is_fight_on:
		var enemy_num = int(node.get_node("AnimatedSprite2D/Label").text)
		#var wave_3_enemies = miniboss_enemies.get_node("wave_3")
		print("floating skull killed: ", enemy_num)
		if enemy_num % wave_3_div == wave_3_rem:
			necromancer_vulnerable()
		elif miniboss_lives == 1 and game_manager.lives >= 0:
			game_manager.take_damage()
			player.apply_knockback(node.global_position)
