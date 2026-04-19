extends Node2D

@export var SPEED: float = 90.0
@export var difficulty: String = "easy"

var direction = -1
var _quiz_triggered: bool = false
var _health: int = 3
var _invincible: bool = false
var _original_modulate: Color

@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var encounter_zone: Area2D = $EncounterZone

const QUIZ_SCENE = preload("res://scenes/quiz_popup.tscn")

func _ready() -> void:
	add_to_group("boss")
	_original_modulate = animated_sprite.modulate

func reset_quiz() -> void:
	_quiz_triggered = false
	encounter_zone.monitoring = true

func _physics_process(delta):
	ray_cast_right.force_raycast_update()
	ray_cast_left.force_raycast_update()
	if ray_cast_right.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
	elif ray_cast_left.is_colliding():
		direction = 1
		animated_sprite.flip_h = false
	position.x += direction * SPEED * delta

func _on_encounter_zone_body_entered(body: Node2D) -> void:
	if _quiz_triggered or not body.is_in_group("player"):
		return
	_quiz_triggered = true
	encounter_zone.monitoring = false
	get_tree().paused = true
	var quiz = QUIZ_SCENE.instantiate()
	get_tree().root.add_child(quiz)
	quiz.start(difficulty)
	quiz.quiz_completed.connect(_on_quiz_completed)

func _on_quiz_completed() -> void:
	get_tree().paused = false

func take_hit() -> void:
	if _health <= 0 or _invincible:
		return
	_invincible = true
	_health -= 1
	$HurtSound.play()
	var tween = create_tween()
	tween.tween_property(animated_sprite, "modulate", Color(3, 3, 3, 1), 0.05)
	tween.tween_property(animated_sprite, "modulate", _original_modulate, 0.12)
	if _health <= 0:
		_die()
	else:
		await get_tree().create_timer(1.0).timeout
		_invincible = false

func _die() -> void:
	set_physics_process(false)
	encounter_zone.monitoring = false
	$StompHitbox.monitoring = false
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.4, 0.3), 0.1)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.15)
	tween.tween_callback(queue_free)
