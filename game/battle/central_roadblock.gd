class_name CentralRoadblock
extends StaticBody2D

func _draw() -> void:
	var outline := Color("2f3331")
	var concrete := Color("737a75")
	var chipped := Color("585f5b")

	draw_polygon(
		PackedVector2Array([
			Vector2(-112, 76),
			Vector2(-104, -48),
			Vector2(-78, -72),
			Vector2(88, -72),
			Vector2(112, -48),
			Vector2(112, 76),
		]),
		PackedColorArray([outline])
	)
	draw_polygon(
		PackedVector2Array([
			Vector2(-102, 66),
			Vector2(-96, -42),
			Vector2(-70, -62),
			Vector2(80, -62),
			Vector2(102, -42),
			Vector2(102, 66),
		]),
		PackedColorArray([concrete])
	)

	draw_line(Vector2(-72, -52), Vector2(-32, 8), chipped, 8.0)
	draw_line(Vector2(-30, 8), Vector2(-58, 44), chipped, 7.0)
	draw_line(Vector2(38, -57), Vector2(10, 6), chipped, 7.0)
	draw_line(Vector2(10, 6), Vector2(54, 48), chipped, 7.0)

	draw_rect(Rect2(-101, 24, 203, 15), Color("b79f66"))
