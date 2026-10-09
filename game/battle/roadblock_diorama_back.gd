class_name RoadblockDioramaBack
extends Node2D

# Roadblock Trial visual-only pilot. The battle collision, aim, AI, and mission
# coordinates are owned by the original scene and are never changed here.
# Unlike the legacy full-screen panorama, the road is world-anchored while
# far art, roadside architecture, and foreground surfaces occupy distinct planes.
const ProductionArtScript := preload("res://game/presentation/production_art.gd")
const BACKDROP_PATH := "res://assets/art/production/battle/outskirts/roadblock_trial_backdrop.png"
const SKY_PATH := "res://assets/art/production/battle/outskirts/outskirts_sky_far.svg"
const MID_PATH := "res://assets/art/production/battle/outskirts/outskirts_midground.svg"
const LANDMARK_PATH := "res://assets/art/production/battle/outskirts/roadblock_trial_landmark.svg"
const ROAD_PATH := "res://assets/art/production/battle/outskirts/outskirts_road.svg"

const WORLD_WIDTH := 2160.0
const WORLD_HEIGHT := 1280.0
const ROAD_TOP := 930.0
const CONTACT_LINE := 1035.0

var _backdrop: Texture2D
var _sky: Texture2D
var _mid: Texture2D
var _landmark: Texture2D
var _road: Texture2D
var _camera_x := 1080.0


func _ready() -> void:
	if ResourceLoader.exists(BACKDROP_PATH):
		_backdrop = load(BACKDROP_PATH) as Texture2D
	_sky = ProductionArtScript.texture_from_svg(SKY_PATH)
	_mid = ProductionArtScript.texture_from_svg(MID_PATH)
	_landmark = ProductionArtScript.texture_from_svg(LANDMARK_PATH)
	_road = ProductionArtScript.texture_from_svg(ROAD_PATH)
	queue_redraw()


func _process(_delta: float) -> void:
	if not visible:
		return
	var active_camera := get_viewport().get_camera_2d()
	if active_camera == null:
		return
	var next_x := active_camera.get_screen_center_position().x
	if absf(next_x - _camera_x) > 1.0:
		_camera_x = next_x
		queue_redraw()


func _draw() -> void:
	# Empty-space safety at the bottom of taller-than-design phone viewports.
	draw_rect(Rect2(-500.0, 0.0, 3200.0, WORLD_HEIGHT + 220.0), Color("24292c"))
	_draw_distant_panorama()
	_draw_roadside_architecture()
	_draw_world_road()
	_draw_world_details()


func _draw_distant_panorama() -> void:
	# Only the distant upper portion of the old panorama is retained. The ground
	# is no longer painted into the same camera-moving texture as the skyline.
	# It is deliberately over-scanned for player/enemy camera travel.
	var drift := (_camera_x - WORLD_WIDTH * 0.5) * 0.60
	if _backdrop != null:
		var size := _backdrop.get_size()
		var crop_width := minf(size.x, size.y * WORLD_WIDTH / WORLD_HEIGHT)
		var crop_x := (size.x - crop_width) * 0.5
		# Avoid a hard horizontal cut between raster painting and world-space
		# architectural art: fade the lower region progressively into the scene.
		var solid_height := 570.0
		draw_texture_rect_region(
			_backdrop,
			Rect2(-300.0 + drift, 0.0, WORLD_WIDTH + 600.0, solid_height),
			Rect2(crop_x, 0.0, crop_width, size.y * solid_height / WORLD_HEIGHT),
			Color(0.92, 0.95, 1.0, 0.91)
		)
		for band in range(8):
			var y := solid_height + float(band) * 30.0
			var alpha := 0.91 * (1.0 - (float(band) + 0.5) / 8.0)
			draw_texture_rect_region(
				_backdrop,
				Rect2(-300.0 + drift, y, WORLD_WIDTH + 600.0, 30.0),
				Rect2(crop_x, size.y * y / WORLD_HEIGHT, crop_width, size.y * 30.0 / WORLD_HEIGHT),
				Color(0.92, 0.95, 1.0, alpha)
			)
	elif _sky != null:
		draw_texture_rect(
			_sky, Rect2(-300.0 + drift, 0.0, WORLD_WIDTH + 600.0, ROAD_TOP),
			false
		)
	# Warm dust isolates distant detail from the closer physical checkpoint.
	draw_rect(Rect2(-200.0, 600.0, 2600.0, 190.0), Color(0.83, 0.54, 0.36, 0.15))


func _draw_roadside_architecture() -> void:
	# Midground and mission landmark are separate transparent authored pieces.
	# The landmark is world-anchored: its supports terminate at the same shoulder
	# that the combatants occupy rather than drifting with the sky painting.
	if _mid != null:
		var drift := (_camera_x - WORLD_WIDTH * 0.5) * 0.13
		draw_texture_rect(_mid, Rect2(-90.0 + drift, 0.0, 2340.0, ROAD_TOP), false, Color(0.80, 0.84, 0.86, 0.76))
	if _landmark != null:
		draw_texture_rect(_landmark, Rect2(0.0, 0.0, WORLD_WIDTH, ROAD_TOP), false)
	# Behind the live actors: the site genuinely meets the roadside.
	draw_rect(Rect2(0.0, 894.0, WORLD_WIDTH, 38.0), Color("293033"))
	draw_rect(Rect2(0.0, 912.0, WORLD_WIDTH, 15.0), Color("6d685b"))
	draw_line(Vector2(0.0, 920.0), Vector2(WORLD_WIDTH, 920.0), Color("db9c68", 0.31), 5.0)

	# Retaining seams and collapsed shoulder sections, kept away from tactical
	# silhouettes. These are visual only, not hidden collision barriers.
	for x in [110.0, 720.0, 1335.0, 2030.0]:
		draw_rect(Rect2(x, 894.0, 180.0, 26.0), Color("474a45", 0.82))
		draw_line(Vector2(x + 16.0, 896.0), Vector2(x + 155.0, 896.0), Color("b68667", 0.35), 3.0)
		draw_line(Vector2(x + 70.0, 910.0), Vector2(x + 82.0, 930.0), Color("222c2c", 0.56), 5.0)


func _draw_world_road() -> void:
	# Critical separation from the old green-screen composition: the playable
	# road has a fixed world-space contact plane (ground collision top = 1035).
	if _road != null:
		draw_texture_rect(_road, Rect2(0.0, ROAD_TOP, WORLD_WIDTH, 350.0), false)
	else:
		draw_rect(Rect2(0.0, ROAD_TOP, WORLD_WIDTH, 350.0), Color("383b39"))
	draw_rect(Rect2(0.0, ROAD_TOP, WORLD_WIDTH, 29.0), Color("675f51", 0.42))
	draw_line(Vector2(0.0, ROAD_TOP + 5.0), Vector2(WORLD_WIDTH, ROAD_TOP + 5.0), Color("e5ae7b", 0.30), 5.0)

	# The flyover physically shades sections of the playable road. This
	# deliberately sits BEHIND the characters, vehicles, and interactives.
	for shadow in [
		PackedVector2Array([Vector2(350, 929), Vector2(520, 929), Vector2(720, 1200), Vector2(485, 1200)]),
		PackedVector2Array([Vector2(1110, 930), Vector2(1290, 930), Vector2(1510, 1200), Vector2(1260, 1200)]),
		PackedVector2Array([Vector2(1750, 930), Vector2(1920, 930), Vector2(2130, 1200), Vector2(1910, 1200)]),
	]:
		draw_colored_polygon(shadow, Color("18242a", 0.25))
	# Ground plane transitions; the collision remains exactly where it was.
	draw_line(Vector2(0.0, CONTACT_LINE), Vector2(WORLD_WIDTH, CONTACT_LINE), Color("e4ae7a", 0.08), 18.0)
	draw_line(Vector2(0.0, 1085.0), Vector2(WORLD_WIDTH, 1085.0), Color("182126", 0.14), 38.0)
	draw_rect(Rect2(0.0, 1252.0, WORLD_WIDTH, 140.0), Color("131d22", 0.44))


func _draw_world_details() -> void:
	# Ground stains, wheel ruts and broken asphalt belong to world positions.
	# They do not move with the far background during aiming or projectile follow.
	for x in [180.0, 345.0, 670.0, 840.0, 1190.0, 1350.0, 1650.0, 1980.0]:
		draw_set_transform(Vector2(x, 1060.0 + fmod(x, 4.0) * 15.0), 0.0, Vector2(1.7, 0.20))
		draw_circle(Vector2.ZERO, 62.0, Color("172326", 0.17))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	for x in [80.0, 610.0, 900.0, 1450.0, 2020.0]:
		draw_line(Vector2(x, 1150.0), Vector2(x + 45.0, 1129.0), Color("171f24", 0.52), 5.0)
		draw_line(Vector2(x + 45.0, 1129.0), Vector2(x + 81.0, 1142.0), Color("171f24", 0.40), 3.0)
		draw_line(Vector2(x + 20.0, 1163.0), Vector2(x + 61.0, 1152.0), Color("c6865b", 0.13), 4.0)

	# Specific road wear below the cast shadows; not a fake interactive object.
	for x in [475.0, 1070.0, 1540.0]:
		draw_line(Vector2(x - 74.0, 1115.0), Vector2(x + 55.0, 1123.0), Color("e6c58a", 0.24), 6.0)
		draw_line(Vector2(x + 15.0, 1122.0), Vector2(x + 80.0, 1126.0), Color("131b20", 0.30), 3.0)
