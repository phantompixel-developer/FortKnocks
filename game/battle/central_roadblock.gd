class_name CentralRoadblock
extends StaticBody2D

func _draw() -> void:
	var outline := Color("171c1b")
	var concrete := Color("69736d")
	var shade := Color("4b5550")
	var chip := Color("3d4742")
	var rust := Color("8f5540")
	var hazard := Color("d4aa55")

	# Poured road barrier with salvaged repair plates and exposed rebar.
	draw_polygon(
		PackedVector2Array([
			Vector2(-114, 76),
			Vector2(-106, -48),
			Vector2(-80, -74),
			Vector2(88, -74),
			Vector2(114, -48),
			Vector2(114, 76),
		]),
		PackedColorArray([outline])
	)
	draw_polygon(
		PackedVector2Array([
			Vector2(-103, 66),
			Vector2(-96, -42),
			Vector2(-70, -63),
			Vector2(79, -63),
			Vector2(103, -42),
			Vector2(103, 66),
		]),
		PackedColorArray([concrete])
	)
	draw_polygon(
		PackedVector2Array([
			Vector2(-96, 42),
			Vector2(-72, -50),
			Vector2(-18, -57),
			Vector2(-30, 62),
		]),
		PackedColorArray([shade])
	)

	# Exposed reinforcing steel and authored cracks.
	draw_line(Vector2(-78, -60), Vector2(-90, -88), rust, 5.0)
	draw_line(Vector2(-63, -64), Vector2(-65, -94), rust, 4.0)
	draw_line(Vector2(78, -61), Vector2(91, -87), rust, 5.0)
	draw_line(Vector2(-54, -46), Vector2(-23, 2), chip, 7.0)
	draw_line(Vector2(-24, 2), Vector2(-51, 40), chip, 6.0)
	draw_line(Vector2(43, -55), Vector2(15, 8), chip, 6.0)
	draw_line(Vector2(15, 8), Vector2(55, 46), chip, 6.0)

	# Faded road-maintenance striping ties the blocker to the Outskirts language.
	for x in [-88.0, -48.0, -8.0, 32.0, 72.0]:
		draw_line(Vector2(x, 52), Vector2(x + 24, 26), hazard if int((x + 88.0) / 40.0) % 2 == 0 else rust, 10.0)

	# A bolted repair plate implies repeated reuse rather than clean military equipment.
	draw_rect(Rect2(54, -20, 43, 35), Color("46524c"))
	for p in [Vector2(61, -13), Vector2(89, -13), Vector2(61, 7), Vector2(89, 7)]:
		draw_circle(p, 3.0, outline)
