class_name FortKnocksScreenBackdrop
extends Node2D

@export_range(0, 2, 1) var variant := 0

func _draw() -> void:
	var coal := Color("111820")
	var sky_top := Color("415c70")
	var sky_mid := Color("87675b")
	var sunset := Color("d77743")
	var far := Color("293943")
	var mid := Color("1d2b33")
	var plate := Color("18232c")
	var hazard := Color("e7ad3c")
	var rust := Color("a95535")
	var warm := Color("f0a14a")

	# Layered sunset atmosphere. This remains presentation-only and deliberately
	# keeps the central content area quieter than the locked concept board.
	draw_rect(Rect2(0, 0, 720, 1280), coal)
	draw_rect(Rect2(0, 0, 720, 220), sky_top)
	draw_rect(Rect2(0, 220, 720, 190), sky_mid)
	draw_rect(Rect2(0, 410, 720, 180), sunset.darkened(0.22))
	draw_circle(Vector2(590, 250), 76.0, Color(warm, 0.62))

	# Far city / roadside silhouettes.
	for rect in [
		Rect2(0, 342, 90, 248),
		Rect2(102, 392, 116, 198),
		Rect2(236, 305, 82, 285),
		Rect2(334, 370, 132, 220),
		Rect2(486, 326, 96, 264),
		Rect2(596, 358, 124, 232),
	]:
		draw_rect(rect, far)
	for rect in [
		Rect2(0, 454, 138, 136),
		Rect2(154, 430, 120, 160),
		Rect2(294, 468, 164, 122),
		Rect2(478, 438, 112, 152),
		Rect2(606, 462, 114, 128),
	]:
		draw_rect(rect, mid)

	# Utility silhouettes give the non-battle screens the same world as Outskirts.
	for x in [76.0, 356.0, 648.0]:
		draw_line(Vector2(x, 374), Vector2(x, 585), mid, 8.0)
		draw_line(Vector2(x - 34.0, 414), Vector2(x + 34.0, 414), mid, 6.0)

	# Dark welded lower environment rather than a flat menu slab.
	draw_rect(Rect2(0, 590, 720, 690), plate)
	draw_line(Vector2(0, 590), Vector2(720, 590), Color("46535b"), 5.0)
	draw_rect(Rect2(0, 610, 720, 42), Color("10171d"))
	for x in range(32, 720, 88):
		draw_circle(Vector2(x, 630), 4.0, Color("080c0f"))

	match variant:
		1:
			_draw_garage_motif(hazard, rust, warm)
		2:
			_draw_workshop_motif(hazard, rust, warm)
		_:
			_draw_command_motif(hazard, rust)

func _draw_command_motif(hazard: Color, rust: Color) -> void:
	# Recovered physical route board language.
	draw_rect(Rect2(56, 700, 608, 360), Color("2a2722", 0.72))
	draw_rect(Rect2(72, 718, 576, 324), Color("6a5843", 0.18))
	var route := PackedVector2Array([
		Vector2(124, 958),
		Vector2(226, 892),
		Vector2(318, 914),
		Vector2(410, 836),
		Vector2(526, 774),
	])
	for i in range(route.size() - 1):
		draw_line(route[i], route[i + 1], Color("e4d3b0", 0.42), 4.0)
	for i in range(route.size()):
		var active := i < 3
		draw_circle(route[i], 12.0, Color(hazard if active else rust, 0.62 if active else 0.34))
		draw_circle(route[i], 5.0, Color("171c21"))
	for card in [
		Rect2(100, 742, 126, 70),
		Rect2(246, 774, 132, 74),
		Rect2(430, 708, 150, 78),
	]:
		draw_rect(card, Color("d7c7a7", 0.16))
		draw_line(card.position + Vector2(12, 18), Vector2(card.end.x - 12, card.position.y + 18), Color(rust, 0.5), 3.0)

func _draw_garage_motif(hazard: Color, rust: Color, warm: Color) -> void:
	# Structural bay, overhead lamps and floor guide create a physical garage.
	draw_line(Vector2(58, 700), Vector2(662, 700), Color("0b1014"), 18.0)
	for x in [92.0, 360.0, 628.0]:
		draw_line(Vector2(x, 700), Vector2(x, 1020), Color("26343d"), 14.0)
	for x in [188.0, 532.0]:
		draw_line(Vector2(x, 704), Vector2(x, 754), Color("0c1115"), 5.0)
		draw_circle(Vector2(x, 766), 32.0, Color(warm, 0.16))
		draw_circle(Vector2(x, 766), 9.0, Color(warm, 0.72))
	draw_line(Vector2(78, 968), Vector2(642, 968), Color(hazard, 0.20), 10.0)
	for x in range(96, 640, 92):
		draw_line(Vector2(x, 968), Vector2(x + 44, 1006), Color(rust, 0.22), 8.0)

func _draw_workshop_motif(hazard: Color, rust: Color, warm: Color) -> void:
	# Warm task-lit pegboard and bench.
	draw_rect(Rect2(70, 704, 580, 260), Color("273139"))
	for x in range(98, 640, 42):
		for y in range(732, 944, 42):
			draw_circle(Vector2(x, y), 2.5, Color("0e1418"))
	for y in [774.0, 842.0, 910.0]:
		draw_line(Vector2(126, y), Vector2(544, y - 18), Color("121a20"), 14.0)
		draw_line(Vector2(156, y - 2), Vector2(516, y - 16), Color(rust if y < 900.0 else hazard, 0.72), 4.0)
	draw_line(Vector2(92, 1008), Vector2(628, 1008), Color("815137"), 34.0)
	draw_circle(Vector2(520, 690), 56.0, Color(warm, 0.12))
	draw_circle(Vector2(520, 690), 10.0, Color(warm, 0.76))
