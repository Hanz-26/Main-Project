extends Node2D

const SPEED = 60

var direction = -1

@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	add_to_group("enemy")

func _process(delta):
	if ray_cast_right.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
	if ray_cast_left.is_colliding():
		direction = 1
		animated_sprite.flip_h = false
	position.x += direction * SPEED * delta

func take_hit() -> void:
	set_process(false)
	$StompHitbox.monitoring = false
	$HurtSound.play()
	var tween = create_tween()
	tween.tween_property(animated_sprite, "modulate", Color(3, 3, 3, 1), 0.04)
	tween.tween_property(self, "scale", Vector2(1.5, 0.3), 0.08)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.1)
	tween.tween_callback(queue_free)
