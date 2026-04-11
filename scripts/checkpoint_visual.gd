extends Node2D

## Visual checkpoint flag - shows a pole with a colored flag
## Activates when player touches it (changes color)

var activated = false

func _ready():
	# Draw the flag
	queue_redraw()

	# Create trigger area
	var area = Area2D.new()
	area.name = "TriggerArea"
	area.collision_layer = 0
	area.collision_mask = 2
	add_child(area)

	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(20, 40)
	shape.shape = rect
	shape.position = Vector2(0, -15)
	area.add_child(shape)

	area.body_entered.connect(_on_body_entered)

func _draw():
	# Pole (brown)
	draw_rect(Rect2(-1, -35, 3, 40), Color(0.4, 0.25, 0.1))

	# Flag (red if not activated, green if activated)
	var flag_color = Color(0.2, 0.8, 0.2) if activated else Color(0.9, 0.15, 0.15)
	var points = PackedVector2Array([
		Vector2(2, -35),   # Top of pole
		Vector2(16, -28),  # Right point
		Vector2(2, -21),   # Bottom attach
	])
	draw_colored_polygon(points, flag_color)

	# Flag outline
	draw_polyline(points, Color(0, 0, 0), 1.0)

func _on_body_entered(body: Node2D):
	if body.name != "Player" or activated:
		return

	activated = true
	queue_redraw()  # Redraw flag as green

	var game_manager = get_tree().current_scene.get_node_or_null("GameManager")
	if not game_manager:
		game_manager = get_tree().current_scene.get_node_or_null("Game Manager")

	if game_manager:
		game_manager.last_safe_position = global_position
		print("Checkpoint flag activated at ", global_position)
