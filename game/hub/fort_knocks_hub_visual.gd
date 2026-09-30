class_name FortKnocksHubVisual
extends Node2D

var _platform_id := "run_down_compact"
var _module_id := ""

func configure(platform_id: String, module_id := "") -> void:
	_platform_id = platform_id
	_module_id = module_id
	queue_redraw()

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

	_draw_workshop()
	_draw_active_platform()

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

func _draw_workshop() -> void:
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

	if _platform_id == "old_sedan" or _platform_id == "pickup":
		# Buying the first platform upgrade visibly improves the garage corner.
		draw_rect(Rect2(350, 686, 316, 18), Color("454d48"))
		draw_line(Vector2(366, 686), Vector2(366, 874), Color("343b37"), 12.0)
		draw_line(Vector2(648, 686), Vector2(648, 874), Color("343b37"), 12.0)
		draw_rect(Rect2(370, 708, 274, 16), Color("74786c"))
		draw_rect(Rect2(82, 818, 212, 18), Color("686b61"))
		for x in [105.0, 154.0, 203.0, 252.0]:
			draw_rect(Rect2(x, 780, 26, 34), Color("61665f"))

func _draw_active_platform() -> void:
	if _platform_id == "pickup":
		_draw_pickup()
	elif _platform_id == "old_sedan":
		_draw_sedan()
	else:
		_draw_compact()

func _draw_compact() -> void:
	draw_rect(Rect2(405, 780, 220, 74), Color("66544a"))
	draw_rect(Rect2(448, 742, 118, 48), Color("66544a"))
	draw_circle(Vector2(454, 858), 28, Color("292d2b"))
	draw_circle(Vector2(582, 858), 28, Color("292d2b"))
	draw_line(Vector2(470, 750), Vector2(540, 750), Color("8b918a"), 5.0)


func _draw_pickup() -> void:
	var shell := Color("4f5e54")
	draw_rect(Rect2(360, 778, 294, 80), shell)
	draw_polygon(
		PackedVector2Array([
			Vector2(382, 778),
			Vector2(420, 730),
			Vector2(520, 730),
			Vector2(552, 778),
		]),
		PackedColorArray([shell.lightened(0.06)])
	)
	draw_rect(Rect2(438, 739, 58, 30), Color("526965"))
	draw_rect(Rect2(558, 790, 78, 40), shell.darkened(0.08))
	draw_circle(Vector2(416, 862), 31, Color("292d2b"))
	draw_circle(Vector2(604, 862), 31, Color("292d2b"))
	draw_circle(Vector2(416, 862), 15, Color("686d67"))
	draw_circle(Vector2(604, 862), 15, Color("686d67"))

	if _module_id == "spotter_rack":
		draw_line(Vector2(586, 790), Vector2(586, 724), Color("343b37"), 8.0)
		draw_line(Vector2(586, 728), Vector2(620, 712), Color("343b37"), 6.0)
		draw_circle(Vector2(626, 710), 12, Color("798a84"))
	elif _module_id == "ballast_crates":
		draw_rect(Rect2(552, 754, 42, 32), Color("675d46"))
		draw_rect(Rect2(598, 760, 36, 26), Color("75694d"))

func _draw_sedan() -> void:
	var shell := Color("596258")
	draw_rect(Rect2(372, 778, 278, 78), shell)
	draw_polygon(
		PackedVector2Array([
			Vector2(410, 778),
			Vector2(454, 732),
			Vector2(585, 732),
			Vector2(624, 778),
		]),
		PackedColorArray([shell.lightened(0.06)])
	)
	draw_rect(Rect2(462, 740, 54, 30), Color("526965"))
	draw_rect(Rect2(524, 740, 52, 30), Color("526965"))
	draw_line(Vector2(520, 736), Vector2(520, 778), Color("303634"), 5.0)
	draw_circle(Vector2(426, 860), 30, Color("292d2b"))
	draw_circle(Vector2(598, 860), 30, Color("292d2b"))
	draw_circle(Vector2(426, 860), 15, Color("686d67"))
	draw_circle(Vector2(598, 860), 15, Color("686d67"))
	draw_line(Vector2(388, 795), Vector2(406, 788), Color("9b9e8c"), 4.0)
