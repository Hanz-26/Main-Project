extends Node2D

const SPEED = 60
var direction = 1
var start_y: float
@onready var ray_cast_right: RayCast2D = $AnimatedSprite2D/RayCastRight
@onready var ray_cast_left: RayCast2D = $AnimatedSprite2D/RayCastLeft
@onready var ray_cast_ground_right: RayCast2D = $AnimatedSprite2D/RayCastGroundRight
@onready var ray_cast_ground_left: RayCast2D = $AnimatedSprite2D/RayCastGroundLeft
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	start_y = position.y

func _process(delta: float) -> void:
	if ray_cast_right.is_colliding() or not ray_cast_ground_right.is_colliding():
		if direction == 1:
			direction = -1
			animated_sprite.flip_h = true
	if ray_cast_left.is_colliding() or not ray_cast_ground_left.is_colliding():
		if direction == -1:
			direction = 1
			animated_sprite.flip_h = false
	position.x += direction * SPEED * delta
	position.y = start_y
