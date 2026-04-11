extends ParallaxBackground

## Galaxy background with shooting stars.

var drift_speed := 2.0

# Shooting star system
var shooting_stars: Array = []
var star_timer := 0.0
var star_interval := 3.0
var star_layer: ParallaxLayer = null

func _ready() -> void:
	# Create a ParallaxLayer for shooting stars that moves with the camera
	star_layer = ParallaxLayer.new()
	star_layer.name = "ShootingStarLayer"
	star_layer.motion_scale = Vector2(1, 1)
	add_child(star_layer)

func _process(delta: float) -> void:
	scroll_offset.x -= drift_speed * delta
	scroll_offset.y -= drift_speed * 0.3 * delta

	# Spawn shooting stars
	star_timer += delta
	if star_timer >= star_interval:
		star_timer = 0.0
		star_interval = randf_range(1.5, 5.0)
		_spawn_shooting_star()

	# Update shooting stars
	for star in shooting_stars:
		star["pos"] += star["vel"] * delta
		star["life"] -= delta
		star["node"].position = star["pos"]
		star["node"].modulate.a = clamp(star["life"] / star["max_life"], 0.0, 1.0)

	# Remove dead stars
	for i in range(shooting_stars.size() - 1, -1, -1):
		if shooting_stars[i]["life"] <= 0:
			shooting_stars[i]["node"].queue_free()
			shooting_stars.remove_at(i)

func _spawn_shooting_star():
	var camera = get_viewport().get_camera_2d()
	if not camera:
		return

	var vp_size = get_viewport().get_visible_rect().size / camera.zoom
	var cam_pos = camera.global_position

	# Start from random position near top of visible area
	var start_x = cam_pos.x + randf_range(-vp_size.x * 0.5, vp_size.x * 0.5)
	var start_y = cam_pos.y - vp_size.y * 0.4 + randf_range(0, vp_size.y * 0.3)

	# Diagonal direction
	var speed = randf_range(300, 600)
	var angle = randf_range(0.3, 0.8)
	if randi() % 2 == 0:
		angle = -angle
	var vel = Vector2(cos(angle), sin(angle)) * speed

	var life = randf_range(0.4, 0.8)

	# Create the star visual
	var star_node = ColorRect.new()
	star_node.size = Vector2(randf_range(3, 6), 1)
	star_node.color = Color(1, 1, 1, 0.9)
	star_node.position = Vector2(start_x, start_y)
	star_node.rotation = vel.angle()
	star_layer.add_child(star_node)

	shooting_stars.append({
		"node": star_node,
		"pos": Vector2(start_x, start_y),
		"vel": vel,
		"life": life,
		"max_life": life
	})
