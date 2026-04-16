extends Area2D

@onready var timer: Timer = $Timer
@onready var hurt_sound: AudioStreamPlayer = $HurtSound

var _dead_body: Node2D = null
var _is_dead: bool = false

func _on_body_entered(body: Node2D) -> void:
	if _is_dead or not body.is_in_group("player") or body.is_in_group("invincible"):
		return
	_is_dead = true
	_dead_body = body
	Engine.time_scale = 0.5
	hurt_sound.play()
	body.get_node("CollisionShape2D").set_deferred("disabled", true)
	timer.start()


func _on_timer_timeout() -> void:
	Engine.time_scale = 1.0
	_is_dead = false
	var gm = get_tree().get_first_node_in_group("game_manager")
	if gm and gm.checkpoint_pos != Vector2.ZERO and is_instance_valid(_dead_body):
		_dead_body.global_position = gm.checkpoint_pos
		_dead_body.velocity = Vector2.ZERO
		_dead_body.add_to_group("invincible")
		_dead_body.get_node("CollisionShape2D").set_deferred("disabled", false)
		var body_ref = _dead_body
		_dead_body = null
		# Remove invincibility after 1 second
		await get_tree().create_timer(1.0).timeout
		if is_instance_valid(body_ref):
			body_ref.remove_from_group("invincible")
	else:
		get_tree().reload_current_scene()
