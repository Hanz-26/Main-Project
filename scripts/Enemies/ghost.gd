extends Node2D

var SPEED = 50# 120 original, 0.1 for the hunting ghost
var direction = Vector2(1, 0.5)
var is_hunting = false# this variable is true for the one ghost that goes after the player
@onready var ray_casts: Node2D = $AnimatedSprite2D/ray_casts

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if is_hunting:
		SPEED = 0.1
		self.get_node("AnimatedSprite2D/Harm Zone").monitorable = false# makes ghost invincible
		self.get_node("AnimatedSprite2D").modulate = Color(2, 1, 1, .75)# makes ghost red
	else:
		pass
		#activate_ray_cast()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# code below handles movement for the hunting ghost
	if is_hunting:
		var player_location = get_tree().current_scene.get_node("Player").global_position + Vector2(0, -20)# offest is because without it ghost stays below player
		direction = player_location - self.global_position
		#position += direction * SPEED * delta
	else:# regular ghosts; the get_collider() prevents collision with other ghosts
		if (ray_casts.get_node("RayCast2D_up").is_colliding() and ray_casts.get_node("RayCast2D_up").get_collider().name != "Harm Zone"):
			direction.y = 1
			#activate_ray_cast()
		if (ray_casts.get_node("RayCast2D_right").is_colliding() and ray_casts.get_node("RayCast2D_right").get_collider().name != "Harm Zone"):
			direction.x = -1
			#activate_ray_cast()
		if (ray_casts.get_node("RayCast2D_down").is_colliding() and ray_casts.get_node("RayCast2D_down").get_collider().name != "Harm Zone"):
			direction.y = -1
			#activate_ray_cast()
		if (ray_casts.get_node("RayCast2D_left").is_colliding() and ray_casts.get_node("RayCast2D_left").get_collider().name != "Harm Zone"):
			direction.x = 1
			#activate_ray_cast()
	position += direction * SPEED * delta

func activate_ray_cast():
	for n in ray_casts.get_children():
		n.enabled = false
		
	if direction == Vector2(-1,0):
		ray_casts.get_node("RayCast2D_left").enabled = true
		get_node("AnimatedSprite2D").flip_h = true
	if direction == Vector2(1,0):
		ray_casts.get_node("RayCast2D_right").enabled = true
		get_node("AnimatedSprite2D").flip_h = false
	if direction == Vector2(0,-1):
		ray_casts.get_node("RayCast2D_up").enabled = true
	if direction == Vector2(0, 1):
		ray_casts.get_node("RayCast2D_down").enabled = true
