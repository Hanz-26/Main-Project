extends Node2D

const SPEED = 120
var direction = Vector2(-1,0)

@onready var ray_casts: Node2D = $AnimatedSprite2D/ray_casts
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	activate_ray_cast()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += direction * SPEED * delta
	
	#Detect ray cast collision
	if (ray_casts.get_node("RayCast2D_up").is_colliding()):
		direction = Vector2(-1, 0)
		activate_ray_cast()
	if (ray_casts.get_node("RayCast2D_right").is_colliding()):
		direction = Vector2(0, -1)
		activate_ray_cast()
	if (ray_casts.get_node("RayCast2D_down").is_colliding()):
		direction = Vector2(1, 0)
		activate_ray_cast()
	if (ray_casts.get_node("RayCast2D_left").is_colliding()):
		direction = Vector2(0, 1)
		activate_ray_cast()

func activate_ray_cast():
	for n in ray_casts.get_children():
		n.enabled = false
		
	if direction == Vector2(-1,0):
		ray_casts.get_node("RayCast2D_left").enabled = true
		get_node("AnimatedSprite2D/Sprite2D").flip_h = true
	if direction == Vector2(1,0):
		ray_casts.get_node("RayCast2D_right").enabled = true
		get_node("AnimatedSprite2D/Sprite2D").flip_h = false
	if direction == Vector2(0,-1):
		ray_casts.get_node("RayCast2D_up").enabled = true
	if direction == Vector2(0, 1):
		ray_casts.get_node("RayCast2D_down").enabled = true
