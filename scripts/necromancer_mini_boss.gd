extends Node2D

const SKELETON = preload("uid://ctoi65vmimc3d")

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

# code to run when necromancer miniboss is vulnerable
func necromancer_vulnerable():
	print("miniboss is vulnerable")
	get_node("AnimatedSprite2D/Harm Zone").collision_layer = 1
	miniboss_room_platforms.get_node("miniboss_shield").visible = false
	miniboss_room_platforms.get_node("miniboss_shield/CollisionShape2D").set_deferred("disabled", true)
	
#code to run when player enteres mini-boss area
var door_is_closed = false
func _on_area_2d_body_entered(body: Node2D) -> void:
	if not door_is_closed:
		door_is_closed = true
		print("area entered")
		miniboss_room_platforms.get_node("miniboss_gate").visible = true
		miniboss_room_platforms.get_node("miniboss_gate/AnimationPlayer").play("close")
		player.get_node("Camera2D").enabled = false
		for i in range(1, miniboss_room_platforms.get_child_count()):
			miniboss_room_platforms.get_child(i).get_node("CollisionShape2D").set_deferred("disabled", true)

#code to run when player enters miniboss shield area
var is_fight_on = false
func _on_area_2d_body_entered_2(body: Node2D) -> void:
	if (not is_fight_on):
		is_fight_on = true
		print("miniboss activated")
		visible = true
		for i in range(1, miniboss_room_platforms.get_child_count()):
			miniboss_room_platforms.get_child(i).visible = true
			miniboss_room_platforms.get_child(i).get_node("CollisionShape2D").set_deferred("disabled", false)
		spawn_wave_1()

func spawn_wave_1():
	var enemy = SKELETON.instantiate()
	add_child(enemy)
	enemy.global_position = miniboss_room_spawns.get_node("up_spawn").global_position
	
	var wave_1_enemies = miniboss_enemies.get_node("wave_1")
	wave_1_enemies.visible = true
	print("Wave 1 begins")
	miniboss_room_label.text = "Wave 1: mod 2 = 0"
	miniboss_room_label.visible = true
	for n in wave_1_enemies.get_children():
		n.get_node("AnimatedSprite2D/Harm Zone").monitoring = true
		n.get_node("AnimatedSprite2D/Harm Zone").set_deferred("monitorable", true)
		n.get_node("AnimationPlayer").play("move")
	
	#Code below makes it so only one the floating skulls has an even number
	wave_1_enemies.get_child(randi_range(0, 1)).get_node("AnimatedSprite2D/Label").text = str(randi_range(0,49) * 2)
	for n in wave_1_enemies.get_children():
		if n.get_node("AnimatedSprite2D/Label").text == "":
			n.get_node("AnimatedSprite2D/Label").text = str(randi_range(0,49) * 2 + 1)

func _on_wave_1_child_exiting_tree(node: Node) -> void:
	var enemy_num = int(node.get_node("AnimatedSprite2D/Label").text)
	var wave_1_enemies = miniboss_enemies.get_node("wave_1")
	print("floating skull killed: ", enemy_num)
	if enemy_num % 2 == 0:
		for n in wave_1_enemies.get_children():
			n.get_node("AnimatedSprite2D/Label").text = "0" # This makes it so the other floating skull won't automatically hurt player on queue_free()
			n.queue_free()
			necromancer_vulnerable()
	else:
		game_manager.take_damage()
		player.apply_knockback(node.global_position)
	pass # Replace with function body.
