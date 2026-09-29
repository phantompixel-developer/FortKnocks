extends Node2D

const WORLD_WIDTH := 2160.0
const WORLD_HEIGHT := 1280.0
const ROAD_TOP := 930.0

var _variant := 0

func configure_variant(value: int) -> void:
	_variant = clampi(value, 0, 2)
	queue_redraw()

func _draw() -> void:
	# Shared sky / road values keep gameplay silhouettes readable between arenas.
	draw_rect(Rect2(0, 0, WORLD_WIDTH, WORLD_HEIGHT), Color("a9b5b1"))
	draw_rect(Rect2(0, 470, WORLD_WIDTH, 460), Color("8f9b96"))

	match _variant:
		1:
			_draw_overpass_backdrop()
		2:
			_draw_salvage_backdrop()
		_:
			_draw_city_backdrop()

	draw_rect(Rect2(0, ROAD_TOP, WORLD_WIDTH, WORLD_HEIGHT - ROAD_TOP), Color("454946"))
	draw_rect(Rect2(0, ROAD_TOP, WORLD_WIDTH, 18), Color("6c736d"))
	for x in range(40, 2140, 190):
		draw_rect(Rect2(x, 1120, 110, 12), Color("b7aa72"))

	for x in range(120, 2100, 250):
		draw_circle(Vector2(x, 918), 18, Color("5f6660"))
		draw_circle(Vector2(x + 24, 923), 12, Color("555c57"))

func _draw_city_backdrop() -> void:
	var buildings := [
		Rect2(40, 560, 170, 370),
		Rect2(250, 650, 130, 280),
		Rect2(420, 520, 210, 410),
		Rect2(700, 610, 150, 320),
		Rect2(900, 470, 230, 460),
		Rect2(1180, 590, 180, 340),
		Rect2(1410, 505, 260, 425),
		Rect2(1715, 625, 150, 305),
		Rect2(1920, 535, 190, 395),
	]
	for building in buildings:
		draw_rect(building, Color("68736f"))
		draw_rect(Rect2(building.position + Vector2(18, 28), Vector2(22, 30)), Color("49514f"))
		draw_rect(Rect2(building.position + Vector2(58, 28), Vector2(22, 30)), Color("49514f"))

	for x in range(90, 2100, 310):
		draw_rect(Rect2(x, 850, 110, 80), Color("626b65"))
		draw_line(Vector2(x + 10, 850), Vector2(x + 95, 805), Color("565d58"), 9.0)

func _draw_overpass_backdrop() -> void:
	# Broken elevated roadway establishes the high-ground encounter at a glance.
	draw_rect(Rect2(1220, 610, 840, 72), Color("646b67"))
	draw_rect(Rect2(1420, 682, 72, 248), Color("565d59"))
	draw_rect(Rect2(1880, 682, 72, 248), Color("565d59"))
	draw_line(Vector2(1220, 610), Vector2(1390, 535), Color("555c58"), 18.0)
	draw_line(Vector2(2060, 610), Vector2(2140, 560), Color("555c58"), 18.0)

	for x in range(80, 1180, 250):
		draw_rect(Rect2(x, 690, 160, 240), Color("6c7570"))
		draw_rect(Rect2(x + 24, 720, 28, 36), Color("4c5551"))

func _draw_salvage_backdrop() -> void:
	# Stacked scrap silhouettes make this arena read differently without adding
	# production art or gameplay-neutral physics bodies.
	for x in range(70, 2110, 280):
		draw_rect(Rect2(x, 730, 190, 200), Color("656b64"))
		draw_circle(Vector2(x + 48, 720), 34, Color("555c56"))
		draw_circle(Vector2(x + 128, 748), 42, Color("5b615b"))
		draw_line(Vector2(x + 18, 785), Vector2(x + 168, 690), Color("4d534e"), 10.0)

	draw_rect(Rect2(980, 640, 220, 290), Color("59615c"))
	draw_line(Vector2(1010, 650), Vector2(1170, 805), Color("3f4541"), 12.0)
	draw_line(Vector2(1170, 650), Vector2(1010, 805), Color("3f4541"), 12.0)
