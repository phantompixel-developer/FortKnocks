class_name FortKnocksHubVisual
extends Node2D

func _draw() -> void:
	# Early Fort Knocks: intentionally makeshift and readable rather than polished.
	draw_rect(Rect2(0, 0, 720, 1280), Color("9da9a4"))
	draw_rect(Rect2(0, 660, 720, 620), Color("545a55"))

	# Distant broken skyline.
	for building in [
		Rect2(20, 340, 120, 320),
		Rect2(165, 420, 95, 240),
		Rect2(285, 300, 145, 360),
		Rect2(465, 390, 105, 270),
		Rect2(590, 325, 110, 335),
	]:
		draw_rect(building, Color("6a746f"))

	# Corrugated perimeter.
	draw_rect(Rect2(34, 610, 652, 38), Color("3d4541"))
	for x in range(42, 684, 46):
		draw_line(Vector2(x, 612), Vector2(x, 646), Color("757b72"), 6.0)

	# Makeshift workshop tarp.
	draw_rect(Rect2(70, 710, 250, 145), Color("3c4540"))
	draw_polygon(
		PackedVector2Array([
			Vector2(54, 714),
			Vector2(197, 650),
			Vector2(340, 714),
		]),
		PackedColorArray([Color("756f58")])
	)
	draw_line(Vector2(84, 714), Vector2(84, 862), Color("2f3632"), 9.0)
	draw_line(Vector2(307, 714), Vector2(307, 862), Color("2f3632"), 9.0)

	# Wrecked compact car: the first combat-platform identity.
	draw_rect(Rect2(405, 780, 220, 74), Color("66544a"))
	draw_rect(Rect2(448, 742, 118, 48), Color("66544a"))
	draw_circle(Vector2(454, 858), 28, Color("292d2b"))
	draw_circle(Vector2(582, 858), 28, Color("292d2b"))
	draw_line(Vector2(470, 750), Vector2(540, 750), Color("8b918a"), 5.0)

	# Scrap pile and camp fire.
	for offset in [Vector2(380, 910), Vector2(414, 924), Vector2(448, 904), Vector2(478, 928)]:
		draw_circle(offset, 24, Color("6b6d63"))
	draw_circle(Vector2(205, 930), 23, Color("c28a4b"))
	draw_circle(Vector2(205, 930), 11, Color("e2ba65"))

	# Rough gate and watch post imply future visual progression.
	draw_rect(Rect2(70, 900, 26, 170), Color("363d39"))
	draw_rect(Rect2(310, 900, 26, 170), Color("363d39"))
	draw_line(Vector2(84, 900), Vector2(323, 900), Color("4c544f"), 12.0)
	draw_rect(Rect2(612, 655, 22, 182), Color("3b423e"))
	draw_rect(Rect2(580, 646, 86, 18), Color("3b423e"))
