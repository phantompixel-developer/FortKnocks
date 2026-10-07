class_name ArenaPlatform
extends StaticBody2D

const OUTSKIRTS_PLATFORM_TEXTURE_PATH := "res://assets/art/production/battle/shared/outskirts_platform_painterly.png"
const SUBURBS_PLATFORM_TEXTURE_PATH := "res://assets/art/production/battle/suburbs/suburbs_platform_painterly.png"

var platform_size := Vector2(320.0, 80.0)
var visual_style := "outskirts"
var _painterly_texture: Texture2D

func configure(rect: Rect2, style := "outskirts") -> void:
	position = rect.position + rect.size * 0.5
	platform_size = rect.size
	visual_style = style

func _ready() -> void:
	add_to_group("ground_surface")

	var collision_shape := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = platform_size
	collision_shape.shape = shape
	add_child(collision_shape)
	queue_redraw()

func _draw() -> void:
	var rect := Rect2(-platform_size * 0.5, platform_size)
	_draw_platform_contact(rect)
	var texture_path := (
		SUBURBS_PLATFORM_TEXTURE_PATH
		if visual_style == "suburbs"
		else OUTSKIRTS_PLATFORM_TEXTURE_PATH
	)
	if _painterly_texture == null and ResourceLoader.exists(texture_path):
		_painterly_texture = load(texture_path) as Texture2D
	if _painterly_texture != null:
		# Rendering only: the authored face is fitted to the existing mission rect.
		# The RectangleShape2D above remains the sole gameplay geometry.
		var texture_size := _painterly_texture.get_size()
		var source_rect := (
			Rect2(0.0, 68.0, texture_size.x, 585.0)
			if visual_style == "suburbs"
			else Rect2(14.0, 146.0, texture_size.x - 28.0, 467.0)
		)
		draw_texture_rect_region(_painterly_texture, rect, source_rect)
		return
	if visual_style == "suburbs":
		_draw_suburbs_retaining_platform(rect)
		return
	_draw_outskirts_service_platform(rect)

func _draw_platform_contact(rect: Rect2) -> void:
	# Render-only grounding under the collision-authored platform footprint.
	var shadow := Rect2(
		rect.position.x + 12.0,
		rect.end.y - 2.0,
		maxf(8.0, rect.size.x - 24.0),
		12.0
	)
	draw_rect(shadow, Color(0.025, 0.035, 0.040, 0.32))

func _draw_outskirts_service_platform(rect: Rect2) -> void:
	var outline := Color("171d20")
	var concrete := Color("4a504d")
	var mid := Color("555d58")
	var cap := Color("777d75")
	var recess := Color("343b39")
	var rust := Color("91563f")

	draw_rect(rect, outline)
	draw_rect(Rect2(rect.position + Vector2(5.0, 5.0), rect.size - Vector2(10.0, 5.0)), concrete)
	draw_rect(Rect2(rect.position + Vector2(0.0, 2.0), Vector2(rect.size.x, minf(14.0, rect.size.y))), cap)
	draw_rect(Rect2(rect.position + Vector2(6.0, 19.0), Vector2(rect.size.x - 12.0, 10.0)), mid.darkened(0.08))

	for x in range(int(rect.position.x) + 30, int(rect.end.x) - 20, 104):
		var panel_height := maxf(18.0, rect.size.y - 46.0)
		draw_rect(Rect2(float(x), rect.position.y + 32.0, 54.0, panel_height), recess)
		draw_line(
			Vector2(float(x) + 7.0, rect.position.y + 37.0),
			Vector2(float(x) + 42.0, rect.position.y + 49.0),
			Color("69706a", 0.52),
			3.0
		)

	for x in range(int(rect.position.x) + 66, int(rect.end.x) - 26, 188):
		draw_line(
			Vector2(float(x), rect.position.y + 8.0),
			Vector2(float(x) + 26.0, rect.position.y + 28.0),
			rust,
			4.0
		)
	# Chips / water streaks stop elevated geometry reading as pristine greybox blocks.
	for x in range(int(rect.position.x) + 44, int(rect.end.x) - 20, 148):
		draw_line(
			Vector2(float(x), rect.position.y + 34.0),
			Vector2(float(x) - 5.0, rect.end.y - 8.0),
			Color("2b3331", 0.54),
			3.0
		)

func _draw_suburbs_retaining_platform(rect: Rect2) -> void:
	var outline := Color("171d20")
	var concrete := Color("555954")
	var cap := Color("7b776c")
	var recess := Color("3a4140")
	var rust := Color("9b5e43")

	draw_rect(rect, outline)
	draw_rect(
		Rect2(rect.position + Vector2(5.0, 5.0), rect.size - Vector2(10.0, 5.0)),
		concrete
	)
	draw_rect(
		Rect2(rect.position + Vector2(0.0, 2.0), Vector2(rect.size.x, minf(16.0, rect.size.y))),
		cap
	)
	draw_rect(
		Rect2(rect.position + Vector2(6.0, 21.0), Vector2(rect.size.x - 12.0, 8.0)),
		Color("67645e", 0.72)
	)

	for x in range(int(rect.position.x) + 34, int(rect.end.x) - 24, 102):
		draw_rect(
			Rect2(float(x), rect.position.y + 31.0, 48.0, maxf(18.0, rect.size.y - 47.0)),
			recess
		)
		draw_line(
			Vector2(float(x) + 8.0, rect.position.y + 37.0),
			Vector2(float(x) + 38.0, rect.position.y + 53.0),
			Color("656864"),
			3.0
		)

	for x in range(int(rect.position.x) + 58, int(rect.end.x) - 20, 176):
		draw_line(
			Vector2(float(x), rect.position.y + 10.0),
			Vector2(float(x) + 24.0, rect.position.y + 34.0),
			rust,
			4.0
		)
	for x in range(int(rect.position.x) + 116, int(rect.end.x) - 20, 214):
		draw_line(
			Vector2(float(x), rect.position.y + 38.0),
			Vector2(float(x) - 7.0, rect.end.y - 10.0),
			Color("303735", 0.52),
			3.0
		)
