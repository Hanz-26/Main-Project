extends Node2D

const COLORS := [
	Color(1.00, 0.20, 0.20),
	Color(0.20, 0.85, 0.25),
	Color(0.20, 0.45, 1.00),
	Color(1.00, 0.88, 0.10),
	Color(1.00, 0.35, 0.80),
	Color(0.75, 0.20, 1.00),
	Color(0.10, 0.90, 0.90),
]

var _pieces: Array = []

func _ready() -> void:
	var size := get_viewport_rect().size
	for i in 120:
		_pieces.append({
			"x":         randf() * size.x,
			"y":         randf_range(-size.y, 0.0),
			"vx":        randf_range(-30.0, 30.0),
			"vy":        randf_range(80.0, 200.0),
			"rot":       randf() * TAU,
			"rot_speed": randf_range(-5.0, 5.0),
			"w":         randf_range(5.0, 11.0),
			"h":         randf_range(7.0, 15.0),
			"color":     COLORS[randi() % COLORS.size()],
		})


func _process(delta: float) -> void:
	var size := get_viewport_rect().size
	for p in _pieces:
		p["x"] += p["vx"] * delta
		p["y"] += p["vy"] * delta
		p["rot"] += p["rot_speed"] * delta
		if p["y"] > size.y + 20.0:
			p["y"] = -20.0
			p["x"] = randf() * size.x
	queue_redraw()


func _draw() -> void:
	for p in _pieces:
		var hw: float = p["w"] * 0.5
		var hh: float = p["h"] * 0.5
		var c := cos(p["rot"])
		var s := sin(p["rot"])
		var corners := PackedVector2Array([
			Vector2(-hw, -hh), Vector2(hw, -hh),
			Vector2(hw,  hh),  Vector2(-hw, hh),
		])
		for i in corners.size():
			var px: float = corners[i].x
			var py: float = corners[i].y
			corners[i] = Vector2(
				px * c - py * s + p["x"],
				px * s + py * c + p["y"],
			)
		draw_colored_polygon(corners, p["color"])
