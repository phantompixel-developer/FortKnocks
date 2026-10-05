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
	# Command room surrounds the real recovered map surface. Do not draw a
	# second fake route here; route state belongs exclusively to RouteVisual.
	draw_rect(Rect2(34, 230, 652, 838), Color("161d21", 0.88))
	draw_rect(Rect2(46, 244, 628, 804), Color("252622", 0.76))
	draw_line(Vector2(46, 244), Vector2(674, 244), Color("0b1014"), 16.0)
	for x in [64.0, 656.0]:
		draw_line(Vector2(x, 244), Vector2(x, 1050), Color("3a332a"), 12.0)
	# Pinned scraps and route notes around, not on top of, the functional map.
	for card in [
		Rect2(58, 284, 92, 58),
		Rect2(566, 300, 92, 64),
		Rect2(64, 930, 104, 66),
		Rect2(550, 910, 108, 72),
	]:
		draw_rect(card, Color("d7c7a7", 0.16))
		draw_line(card.position + Vector2(10, 16), Vector2(card.end.x - 10, card.position.y + 16), Color(rust, 0.48), 3.0)
	for x in [176.0, 544.0]:
		draw_line(Vector2(x, 230), Vector2(x, 268), Color("0c1115"), 5.0)
		draw_circle(Vector2(x, 280), 38.0, Color(hazard, 0.08))
		draw_circle(Vector2(x, 280), 7.0, Color(hazard, 0.62))

func _draw_garage_motif(hazard: Color, rust: Color, warm: Color) -> void:
	# The garage is a room first: broad structural bay, task lights and a floor
	# that visually receives the selected platform instead of framing it as UI.
	draw_rect(Rect2(34, 204, 652, 838), Color("121b21", 0.90))
	draw_rect(Rect2(48, 222, 624, 470), Color("1c2930", 0.86))
	draw_line(Vector2(48, 222), Vector2(672, 222), Color("0b1014"), 18.0)
	for x in [72.0, 360.0, 648.0]:
		draw_line(Vector2(x, 222), Vector2(x, 1018), Color("26343d"), 14.0)
	for x in [188.0, 532.0]:
		draw_line(Vector2(x, 226), Vector2(x, 266), Color("0c1115"), 6.0)
		draw_circle(Vector2(x, 282), 72.0, Color(warm, 0.10))
		draw_circle(Vector2(x, 282), 11.0, Color(warm, 0.82))
	draw_rect(Rect2(48, 692, 624, 350), Color("171d20", 0.94))
	draw_line(Vector2(72, 692), Vector2(648, 692), Color("526068"), 6.0)
	draw_line(Vector2(88, 650), Vector2(632, 650), Color(hazard, 0.18), 9.0)
	for x in range(92, 640, 92):
		draw_line(Vector2(x, 682), Vector2(x + 48, 720), Color(rust, 0.20), 8.0)
	for y in [764.0, 858.0, 952.0]:
		draw_line(Vector2(72, y), Vector2(648, y), Color("2a353a", 0.48), 3.0)

func _draw_workshop_motif(hazard: Color, rust: Color, warm: Color) -> void:
	# Full-height task wall: hardware art can now live directly on the pegboard
	# instead of being hidden inside two opaque menu cards.
	draw_rect(Rect2(44, 198, 632, 862), Color("19242a", 0.94))
	draw_rect(Rect2(64, 218, 592, 716), Color("273139"))
	for x in range(88, 648, 36):
		for y in range(240, 922, 36):
			draw_circle(Vector2(x, y), 2.2, Color("0e1418"))
	draw_line(Vector2(72, 468), Vector2(648, 468), Color("121a20"), 11.0)
	draw_line(Vector2(72, 742), Vector2(648, 742), Color("121a20"), 11.0)
	draw_line(Vector2(88, 982), Vector2(632, 982), Color("815137"), 34.0)
	draw_rect(Rect2(100, 1000, 520, 46), Color("30251e"))
	for x in [160.0, 560.0]:
		draw_line(Vector2(x, 1044), Vector2(x, 1096), Color("242d2d"), 12.0)
	for x in [184.0, 536.0]:
		draw_line(Vector2(x, 202), Vector2(x, 238), Color("0c1115"), 6.0)
		draw_circle(Vector2(x, 252), 64.0, Color(warm, 0.10))
		draw_circle(Vector2(x, 252), 10.0, Color(warm, 0.80))
	draw_line(Vector2(108, 496), Vector2(260, 474), Color(rust, 0.42), 4.0)
	draw_line(Vector2(456, 750), Vector2(602, 730), Color(hazard, 0.38), 4.0)
