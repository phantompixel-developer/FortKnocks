class_name PlatformShowcase
extends Control

const ProductionArtScript := preload("res://game/presentation/production_art.gd")
const COMPACT_TEXTURE_PATH := "res://assets/art/production/vehicles/run_down_compact.svg"

var _compact_texture: Texture2D

var _platform_id := "run_down_compact"
var _module_id := ""

func configure(platform_id: String, module_id := "") -> void:
	_platform_id = platform_id
	_module_id = module_id
	queue_redraw()

func _draw() -> void:
	var center := size * 0.5
	draw_ellipse_shadow(center + Vector2(0, 54), Vector2(minf(size.x * 0.38, 205.0), 22.0))

	if _platform_id == "run_down_compact":
		if _compact_texture == null:
			_compact_texture = ProductionArtScript.texture_from_svg(COMPACT_TEXTURE_PATH)
		if _compact_texture == null:
			_draw_fallback_platform(center)
			return
		var target_width := minf(size.x - 38.0, 430.0)
		var target_height := target_width * 0.5
		var target := Rect2(
			center.x - target_width * 0.5,
			center.y - target_height * 0.53,
			target_width,
			target_height
		)
		draw_texture_rect(_compact_texture, target, false)
		return

	_draw_fallback_platform(center)

func draw_ellipse_shadow(center: Vector2, radii: Vector2) -> void:
	# Polygon approximation avoids a separate texture dependency for the showcase floor shadow.
	var points := PackedVector2Array()
	for i in range(24):
		var angle := TAU * float(i) / 24.0
		points.append(center + Vector2(cos(angle) * radii.x, sin(angle) * radii.y))
	draw_colored_polygon(points, Color(0.02, 0.03, 0.035, 0.58))

func _draw_fallback_platform(center: Vector2) -> void:
	# Temporary silhouettes for platforms that have not yet received production art.
	# They are intentionally restrained so the authored Compact is visibly the new quality bar.
	var body_width := 340.0
	var body_height := 74.0
	var shell := Color("465b58")
	match _platform_id:
		"old_sedan":
			body_width = 390.0
			shell = Color("53645f")
		"pickup":
			body_width = 410.0
			shell = Color("4a625c")
		"improvised_technical":
			body_width = 430.0
			body_height = 82.0
			shell = Color("405751")

	var left := center.x - body_width * 0.5
	var top := center.y - 28.0
	draw_rect(Rect2(left, top, body_width, body_height), Color("0b1114"))
	draw_rect(Rect2(left + 7.0, top + 7.0, body_width - 14.0, body_height - 14.0), shell)

	if _platform_id == "old_sedan":
		draw_polygon(
			PackedVector2Array([
				Vector2(left + 72.0, top + 4.0),
				Vector2(left + 132.0, top - 58.0),
				Vector2(left + body_width - 92.0, top - 58.0),
				Vector2(left + body_width - 28.0, top + 4.0),
			]),
			PackedColorArray([shell.lightened(0.08)])
		)
	elif _platform_id == "pickup" or _platform_id == "improvised_technical":
		draw_polygon(
			PackedVector2Array([
				Vector2(left + 54.0, top + 4.0),
				Vector2(left + 104.0, top - 64.0),
				Vector2(left + 225.0, top - 64.0),
				Vector2(left + 272.0, top + 4.0),
			]),
			PackedColorArray([shell.lightened(0.07)])
		)
		draw_rect(Rect2(left + body_width - 132.0, top + 10.0, 112.0, 36.0), shell.darkened(0.15))
		if _platform_id == "improvised_technical":
			draw_line(Vector2(left + body_width - 140.0, top), Vector2(left + body_width - 140.0, top - 82.0), Color("111820"), 8.0)
			draw_line(Vector2(left + body_width - 140.0, top - 80.0), Vector2(left + body_width - 36.0, top - 80.0), Color("111820"), 8.0)
			draw_line(Vector2(left + body_width - 36.0, top - 80.0), Vector2(left + body_width - 36.0, top + 4.0), Color("111820"), 8.0)
	else:
		draw_polygon(
			PackedVector2Array([
				Vector2(left + 64.0, top + 4.0),
				Vector2(left + 104.0, top - 52.0),
				Vector2(left + 228.0, top - 52.0),
				Vector2(left + 276.0, top + 4.0),
			]),
			PackedColorArray([shell.lightened(0.07)])
		)

	for x in [left + 72.0, left + body_width - 72.0]:
		draw_circle(Vector2(x, top + body_height), 34.0, Color("0a0f12"))
		draw_circle(Vector2(x, top + body_height), 17.0, Color("555e60"))

	draw_line(Vector2(left + body_width * 0.51, top + 46.0), Vector2(left + body_width * 0.55, top + 22.0), Color("e7ad3c"), 7.0)
	draw_line(Vector2(left + body_width * 0.56, top + 46.0), Vector2(left + body_width * 0.60, top + 22.0), Color("b65c36"), 7.0)
