class_name PlatformShowcase
extends Control

const ProductionArtScript := preload("res://game/presentation/production_art.gd")
const COMPACT_TEXTURE_PATH := "res://assets/art/production/vehicles/run_down_compact.svg"
const SEDAN_TEXTURE_PATH := "res://assets/art/production/vehicles/old_sedan.svg"
const PICKUP_TEXTURE_PATH := "res://assets/art/production/vehicles/pickup.svg"
const TECHNICAL_TEXTURE_PATH := "res://assets/art/production/vehicles/improvised_technical.svg"

var _textures: Dictionary = {}

var _platform_id := "run_down_compact"
var _module_id := ""

func configure(platform_id: String, module_id := "") -> void:
	_platform_id = platform_id
	_module_id = module_id
	queue_redraw()

func _draw() -> void:
	var center := size * 0.5
	draw_ellipse_shadow(center + Vector2(0, 54), Vector2(minf(size.x * 0.38, 205.0), 22.0))

	var texture := _texture_for_platform(_platform_id)
	if texture != null:
		var target_width := minf(size.x - 38.0, 440.0)
		var aspect := 0.50 if _platform_id == "run_down_compact" else 0.47
		var target_height := target_width * aspect
		var target := Rect2(
			center.x - target_width * 0.5,
			center.y - target_height * 0.52,
			target_width,
			target_height
		)
		draw_texture_rect(texture, target, false)
		_draw_module_indicator(center, target_width, target_height)
		return

	_draw_fallback_platform(center)


func _texture_for_platform(platform_id: String) -> Texture2D:
	if _textures.has(platform_id):
		return _textures[platform_id] as Texture2D

	var path := ""
	match platform_id:
		"run_down_compact":
			path = COMPACT_TEXTURE_PATH
		"old_sedan":
			path = SEDAN_TEXTURE_PATH
		"pickup":
			path = PICKUP_TEXTURE_PATH
		"improvised_technical":
			path = TECHNICAL_TEXTURE_PATH
		_:
			return null

	var texture: Texture2D = ProductionArtScript.texture_from_svg(path)
	_textures[platform_id] = texture
	return texture

func _draw_module_indicator(center: Vector2, width: float, height: float) -> void:
	if _module_id.is_empty():
		return

	var accent := Color("77b6bf")
	var p := center + Vector2(width * 0.30, -height * 0.27)
	match _module_id:
		"spotter_rack":
			draw_line(p, p + Vector2(0, -34), Color("18232c"), 7.0)
			draw_circle(p + Vector2(0, -40), 11.0, Color("5d918e"))
			draw_circle(p + Vector2(0, -40), 4.0, Color("d3f1eb"))
		"ballast_crates":
			draw_rect(Rect2(p.x - 36, p.y - 18, 31, 24), Color("6d5d43"))
			draw_rect(Rect2(p.x + 1, p.y - 14, 28, 20), Color("806c4b"))
		"twin_field_rack":
			draw_rect(Rect2(p.x - 26, p.y - 40, 20, 42), Color("53615d"))
			draw_rect(Rect2(p.x + 4, p.y - 40, 20, 42), Color("405b56"))
			draw_circle(p + Vector2(-16, -30), 4.0, Color("e7ad3c"))
			draw_circle(p + Vector2(14, -30), 4.0, accent)
		"stabilizer_rig":
			draw_line(p + Vector2(-18, 0), p + Vector2(-34, 30), Color("65716d"), 6.0)
			draw_line(p + Vector2(18, 0), p + Vector2(34, 30), Color("65716d"), 6.0)
			draw_line(p + Vector2(-42, 30), p + Vector2(-25, 30), Color("8a7b5e"), 6.0)
			draw_line(p + Vector2(25, 30), p + Vector2(42, 30), Color("8a7b5e"), 6.0)

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
