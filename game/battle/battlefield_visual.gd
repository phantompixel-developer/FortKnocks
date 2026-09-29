extends Node2D

const WORLD_WIDTH := 2160.0
const WORLD_HEIGHT := 1280.0
const ROAD_TOP := 930.0

func _draw() -> void:
	# Sky and haze.
	draw_rect(Rect2(0, 0, WORLD_WIDTH, WORLD_HEIGHT), Color("a9b5b1"))
	draw_rect(Rect2(0, 470, WORLD_WIDTH, 460), Color("8f9b96"))

	# Distant ruined skyline.
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

	# Midground barriers and rubble.
	for x in range(90, 2100, 310):
		draw_rect(Rect2(x, 850, 110, 80), Color("626b65"))
		draw_line(Vector2(x + 10, 850), Vector2(x + 95, 805), Color("565d58"), 9.0)

	# Road and shoulder.
	draw_rect(Rect2(0, ROAD_TOP, WORLD_WIDTH, WORLD_HEIGHT - ROAD_TOP), Color("454946"))
	draw_rect(Rect2(0, ROAD_TOP, WORLD_WIDTH, 18), Color("6c736d"))
	for x in range(40, 2140, 190):
		draw_rect(Rect2(x, 1120, 110, 12), Color("b7aa72"))

	# Small rubble silhouettes.
	for x in range(120, 2100, 250):
		draw_circle(Vector2(x, 918), 18, Color("5f6660"))
		draw_circle(Vector2(x + 24, 923), 12, Color("555c57"))
