extends Node2D

const SPEED = 60
var direction = 1
var timer = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	direction = (randi_range(0, 1) % 2) * 2 - 1# results is either 1 or -1
	if direction == -1:
		self.get_node("AnimatedSprite2D").flip_h = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x += direction * SPEED * delta
	
	if timer > 0:
		timer -= get_physics_process_delta_time()
	else:
		self.get_node("AnimatedSprite2D").flip_h = !self.get_node("AnimatedSprite2D").flip_h
		timer = 3
		direction = -direction

func enemy_take_damage():
	direction = 0
	timer = 100
	self.get_node("AnimatedSprite2D/Harm Zone").monitoring = false
	self.get_node("AnimatedSprite2D/Harm Zone").set_deferred("monitorable", false)
	self.get_node("AnimatedSprite2D").play("death")
	await get_tree().create_timer(10).timeout	
	self.queue_free()
