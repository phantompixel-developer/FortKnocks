class_name ArenaPlatform
extends StaticBody2D

var platform_size := Vector2(320.0, 80.0)
var visual_style := "outskirts"

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
	if visual_style == "suburbs":
		_draw_suburbs_retaining_platform(rect)
		return

	draw_rect(rect, Color("4a4f4c"))
	draw_rect(Rect2(rect.position, Vector2(rect.size.x, minf(14.0, rect.size.y))), Color("747b75"))

	for x in range(int(rect.position.x) + 26, int(rect.end.x) - 18, 86):
		draw_line(
			Vector2(float(x), rect.position.y + 18.0),
			Vector2(float(x) + 28.0, rect.position.y + 46.0),
			Color("343936"),
			5.0
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

	for x in range(int(rect.position.x) + 34, int(rect.end.x) - 24, 92):
		draw_rect(
			Rect2(float(x), rect.position.y + 28.0, 48.0, maxf(18.0, rect.size.y - 44.0)),
			recess
		)
		draw_line(
			Vector2(float(x) + 8.0, rect.position.y + 34.0),
			Vector2(float(x) + 38.0, rect.position.y + 52.0),
			Color("656864"),
			3.0
		)

	for x in range(int(rect.position.x) + 58, int(rect.end.x) - 20, 170):
		draw_line(
			Vector2(float(x), rect.position.y + 10.0),
			Vector2(float(x) + 24.0, rect.position.y + 34.0),
			rust,
			4.0
		)
