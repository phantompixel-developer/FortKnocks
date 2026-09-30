class_name FortKnocksScreenBackdrop
extends Node2D

@export_range(0, 2, 1) var variant := 0

func _draw() -> void:
	var coal := Color("171c1b")
	var haze := Color("27332f")
	var silhouette := Color("202925")
	var plate := Color("303a35")
	var hazard := Color("d4aa55")
	var rust := Color("8e513b")

	draw_rect(Rect2(0, 0, 720, 1280), coal)
	draw_rect(Rect2(0, 0, 720, 520), haze)

	# Outskirts silhouette: broken utilities, low industrial roofs and distant towers.
	for rect in [
		Rect2(0, 330, 112, 260),
		Rect2(128, 390, 148, 200),
		Rect2(300, 300, 96, 290),
		Rect2(420, 360, 172, 230),
		Rect2(610, 322, 110, 268),
	]:
		draw_rect(rect, silhouette)
	draw_line(Vector2(348, 300), Vector2(348, 216), silhouette, 10.0)
	draw_line(Vector2(324, 236), Vector2(374, 236), silhouette, 8.0)
	draw_circle(Vector2(348, 210), 8.0, Color("8a8f79"))

	# A welded lower plate grounds every non-battle screen in the same visual language.
	draw_rect(Rect2(0, 590, 720, 690), plate)
	draw_line(Vector2(0, 590), Vector2(720, 590), Color("4d5a53"), 6.0)
	for x in range(32, 720, 88):
		draw_circle(Vector2(x, 612), 4.0, Color("121716"))

	match variant:
		1:
			_draw_garage_motif(hazard, rust)
		2:
			_draw_workshop_motif(hazard, rust)
		_:
			_draw_command_motif(hazard, rust)

func _draw_command_motif(hazard: Color, rust: Color) -> void:
	# Route-board lines echo chalked convoy planning without becoming a literal map.
	for offset in [0.0, 90.0, 180.0]:
		draw_line(Vector2(56 + offset, 724), Vector2(360 + offset, 918), Color(rust, 0.18), 9.0)
	for p in [Vector2(124, 768), Vector2(252, 850), Vector2(386, 796), Vector2(526, 910)]:
		draw_circle(p, 11.0, Color(hazard, 0.14))

func _draw_garage_motif(hazard: Color, rust: Color) -> void:
	draw_line(Vector2(70, 812), Vector2(650, 812), Color(hazard, 0.12), 16.0)
	for x in range(90, 650, 96):
		draw_line(Vector2(x, 812), Vector2(x + 48, 860), Color(rust, 0.14), 12.0)
	draw_circle(Vector2(184, 932), 66.0, Color("151a18"))
	draw_circle(Vector2(536, 932), 66.0, Color("151a18"))

func _draw_workshop_motif(hazard: Color, rust: Color) -> void:
	for y in [750.0, 850.0, 950.0]:
		draw_line(Vector2(62, y), Vector2(658, y), Color(rust, 0.14), 6.0)
	for x in range(92, 660, 112):
		draw_circle(Vector2(x, 888), 22.0, Color(hazard, 0.08))
