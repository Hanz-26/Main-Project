extends AnimatableBody2D

## How far the platform travels from its starting position (pixels)
@export var move_distance: float = 210.0
## Pixels per second
@export var move_speed: float = 90.0
## True = moves left/right, False = moves up/down
@export var horizontal: bool = true

var _start_pos: Vector2
var _direction: float = 1.0

func _ready() -> void:
	_start_pos = global_position

func _physics_process(delta: float) -> void:
	move_and_collide((Vector2.RIGHT if horizontal else Vector2.DOWN) * _direction * move_speed * delta)

	var offset = global_position - _start_pos
	var dist = offset.x if horizontal else offset.y
	if dist >= move_distance:
		_direction = -1.0
	elif dist <= 0.0:
		_direction = 1.0
