class_name ArenaPlatform
extends StaticBody2D

var platform_size := Vector2(320.0, 80.0)

func configure(rect: Rect2) -> void:
	position = rect.position + rect.size * 0.5
	platform_size = rect.size

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
	draw_rect(rect, Color("4a4f4c"))
	draw_rect(Rect2(rect.position, Vector2(rect.size.x, minf(14.0, rect.size.y))), Color("747b75"))

	for x in range(int(rect.position.x) + 26, int(rect.end.x) - 18, 86):
		draw_line(
			Vector2(float(x), rect.position.y + 18.0),
			Vector2(float(x) + 28.0, rect.position.y + 46.0),
			Color("343936"),
			5.0
		)
