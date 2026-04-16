extends Node2D

## World X where beach ends and desert begins
@export var desert_start_x: float = 3000.0
## World X where desert ends and jungle begins
@export var jungle_start_x: float = 6000.0
## World X where jungle ends and ice begins
@export var ice_start_x: float = 9000.0

const SKY_COLORS: Dictionary = {
	"beach":  [Color(0.35, 0.72, 1.00), Color(0.75, 0.93, 1.00)],
	"desert": [Color(0.98, 0.68, 0.25), Color(1.00, 0.87, 0.55)],
	"jungle": [Color(0.12, 0.42, 0.12), Color(0.28, 0.60, 0.28)],
	"ice":    [Color(0.52, 0.78, 1.00), Color(0.82, 0.93, 1.00)],
}

const SUN_COLORS: Dictionary = {
	"beach":  Color(1.00, 0.95, 0.30),
	"desert": Color(1.00, 0.72, 0.10),
	"jungle": Color(0.88, 1.00, 0.35),
	"ice":    Color(0.75, 0.88, 1.00),
}

var _sun_angle: float = 0.0
var _camera: Camera2D = null

func _ready() -> void:
	z_index = -100
	await get_tree().process_frame
	_camera = get_viewport().get_camera_2d()

func _process(delta: float) -> void:
	_sun_angle += delta * 0.8
	if not _camera:
		_camera = get_viewport().get_camera_2d()
	# Follow the camera's actual rendered position (respects smoothing)
	if _camera:
		global_position = _camera.get_screen_center_position()
	queue_redraw()

func _get_biome(cam_x: float) -> String:
	if cam_x >= ice_start_x:    return "ice"
	if cam_x >= jungle_start_x: return "jungle"
	if cam_x >= desert_start_x: return "desert"
	return "beach"

func _draw() -> void:
	var zoom := _camera.zoom if _camera else Vector2.ONE
	var size := get_viewport_rect().size / zoom
	# Shift origin to top-left of the visible area
	draw_set_transform(-size / 2)
	var biome := _get_biome(global_position.x)
	var top_col: Color = SKY_COLORS[biome][0]
	var bot_col: Color = SKY_COLORS[biome][1]

	# Gradient sky
	var steps := 28
	var band_h: float = size.y / steps + 1.0
	for i in steps:
		var t := float(i) / steps
		draw_rect(Rect2(0, t * size.y, size.x, band_h), top_col.lerp(bot_col, t * t))

	_draw_sun(Vector2(size.x * 0.78, size.y * 0.20), SUN_COLORS[biome], biome)
	_draw_horizon(biome, size)


func _draw_sun(pos: Vector2, color: Color, biome: String) -> void:
	var radius := 36.0
	# Pulse: sun gently breathes in size
	var pulse := sin(_sun_angle * 1.5) * 3.0
	var r := radius + pulse
	var ray_dist := r + 8.0

	# Wide soft glow layers
	draw_circle(pos, r + 28.0, Color(color.r, color.g, color.b, 0.08))
	draw_circle(pos, r + 18.0, Color(color.r, color.g, color.b, 0.14))
	draw_circle(pos, r + 10.0, Color(color.r, color.g, color.b, 0.22))

	# Long outer rays (slow rotation)
	for i in 12:
		var angle := _sun_angle * 0.5 + (TAU / 12.0) * i
		var ray_len := 22.0 + sin(_sun_angle * 2.0 + i) * 5.0
		draw_line(
			pos + Vector2(cos(angle), sin(angle)) * ray_dist,
			pos + Vector2(cos(angle), sin(angle)) * (ray_dist + ray_len),
			color, 3.5)

	# Short inner rays (faster, between outer rays)
	for i in 12:
		var angle := _sun_angle * 0.5 + (TAU / 12.0) * i + TAU / 24.0
		draw_line(
			pos + Vector2(cos(angle), sin(angle)) * ray_dist,
			pos + Vector2(cos(angle), sin(angle)) * (ray_dist + 10.0),
			color.lightened(0.2), 2.0)

	# Sun body
	draw_circle(pos, r, color)

	# Bright inner core
	draw_circle(pos, r * 0.55, color.lightened(0.3))

	# Highlight spot
	draw_circle(pos + Vector2(-r * 0.28, -r * 0.28), r * 0.28, color.lightened(0.55))

	# Ice biome: replace rays with sharp snowflake crystal arms
	if biome == "ice":
		for i in 8:
			var angle := _sun_angle * 0.3 + (TAU / 8.0) * i
			var arm_end := pos + Vector2(cos(angle), sin(angle)) * (r + 20.0)
			draw_line(pos, arm_end, Color(0.88, 0.95, 1.0, 0.70), 2.0)
			# Small crossbar on each arm
			var mid := pos + Vector2(cos(angle), sin(angle)) * (r + 10.0)
			var perp := Vector2(-sin(angle), cos(angle)) * 6.0
			draw_line(mid - perp, mid + perp, Color(0.88, 0.95, 1.0, 0.55), 1.5)


func _draw_horizon(biome: String, size: Vector2) -> void:
	var hy := size.y * 0.70
	match biome:
		"beach":
			draw_rect(Rect2(0, hy, size.x, size.y - hy), Color(0.18, 0.52, 0.90, 0.38))
			for i in 5:
				var wx := float(i) / 4.0 * size.x
				draw_line(Vector2(wx - 20, hy + 4), Vector2(wx + 20, hy + 4), Color(1, 1, 1, 0.25), 2.0)

		"desert":
			var pts := PackedVector2Array([Vector2(0, size.y)])
			for i in 9:
				pts.append(Vector2(float(i) / 8.0 * size.x, hy + sin(i * 1.7 + 0.5) * 18.0))
			pts.append(Vector2(size.x, size.y))
			draw_colored_polygon(pts, Color(0.82, 0.67, 0.32, 0.48))

		"jungle":
			for i in 7:
				var x := float(i) / 6.0 * size.x * 0.9 + size.x * 0.05
				var h := 55.0 + fmod(float(i) * 17.3, 32.0)
				draw_rect(Rect2(x - 3, hy, 6, h * 0.35), Color(0.18, 0.10, 0.04, 0.50))
				draw_circle(Vector2(x, hy - h * 0.30), h * 0.32, Color(0.08, 0.30, 0.08, 0.50))

		"ice":
			draw_rect(Rect2(0, hy, size.x, size.y - hy), Color(0.82, 0.91, 1.0, 0.42))
			for i in 10:
				var x := float(i) / 9.0 * size.x
				var sh := 18.0 + fmod(float(i) * 13.7, 16.0)
				draw_colored_polygon(PackedVector2Array([
					Vector2(x - 7, hy + 2),
					Vector2(x,     hy - sh),
					Vector2(x + 7, hy + 2),
				]), Color(0.72, 0.86, 1.0, 0.58))
