extends Node2D

const ProductionArtScript := preload("res://game/presentation/production_art.gd")
const OUTSKIRTS_SKY_FAR_PATH := "res://assets/art/production/battle/outskirts/outskirts_sky_far.svg"
const OUTSKIRTS_MIDGROUND_PATH := "res://assets/art/production/battle/outskirts/outskirts_midground.svg"
const OUTSKIRTS_ROAD_PATH := "res://assets/art/production/battle/outskirts/outskirts_road.svg"
const OUTSKIRTS_FOREGROUND_PATH := "res://assets/art/production/battle/outskirts/outskirts_foreground.svg"
const OUTSKIRTS_LANDMARK_PATHS := {
	"roadblock_trial": "res://assets/art/production/battle/outskirts/roadblock_trial_landmark.svg",
	"high_ground_trial": "res://assets/art/production/battle/outskirts/high_ground_trial_landmark.svg",
	"scrap_gate_trial": "res://assets/art/production/battle/outskirts/scrap_gate_trial_landmark.svg",
	"broken_span": "res://assets/art/production/battle/outskirts/broken_span_landmark.svg",
	"depot_line": "res://assets/art/production/battle/outskirts/depot_line_landmark.svg",
	"outskirts_checkpoint": "res://assets/art/production/battle/outskirts/outskirts_checkpoint_landmark.svg",
}
const SUBURBS_SKY_FAR_PATH := "res://assets/art/production/battle/suburbs/suburbs_sky_far.svg"
const SUBURBS_MIDGROUND_PATH := "res://assets/art/production/battle/suburbs/suburbs_midground.svg"
const SUBURBS_ROAD_PATH := "res://assets/art/production/battle/suburbs/suburbs_road.svg"
const SUBURBS_FOREGROUND_PATH := "res://assets/art/production/battle/suburbs/suburbs_foreground.svg"
const SUBURBS_LANDMARK_PATHS := {
	"suburbs_dead_air": "res://assets/art/production/battle/suburbs/suburbs_dead_air_landmark.svg",
	"suburbs_crossroads": "res://assets/art/production/battle/suburbs/suburbs_crossroads_landmark.svg",
	"suburbs_loaded_up": "res://assets/art/production/battle/suburbs/suburbs_loaded_up_landmark.svg",
	"suburbs_hot_cargo": "res://assets/art/production/battle/suburbs/suburbs_hot_cargo_landmark.svg",
}

const WORLD_WIDTH := 2160.0
const WORLD_HEIGHT := 1280.0
const ROAD_TOP := 930.0
const SCRAP_STACK_OFFSETS: Array[Vector2] = [
	Vector2(0, 0),
	Vector2(32, -44),
	Vector2(86, -9),
]

var _variant := 0
var _outskirts_sky_far: Texture2D
var _outskirts_midground: Texture2D
var _outskirts_road: Texture2D
var _outskirts_foreground: Texture2D
var _outskirts_landmarks: Dictionary = {}
var _suburbs_sky_far: Texture2D
var _suburbs_midground: Texture2D
var _suburbs_road: Texture2D
var _suburbs_foreground: Texture2D
var _suburbs_landmarks: Dictionary = {}
var _mission_id := ""

func configure_variant(value: int) -> void:
	_variant = clampi(value, 0, 3)
	queue_redraw()

func configure_mission(mission_id: String) -> void:
	_mission_id = mission_id
	queue_redraw()

func _draw() -> void:
	_ensure_production_textures()

	if _variant == 3:
		if _has_complete_suburbs_set():
			_draw_production_suburbs()
		else:
			_draw_atmosphere()
			_draw_far_outskirts()
			_draw_suburbs_backdrop()
			_draw_road()
			_draw_foreground_dressing()
		return

	if not _has_complete_outskirts_set():
		_draw_atmosphere()
		_draw_far_outskirts()
		match _variant:
			1:
				_draw_overpass_backdrop()
			2:
				_draw_salvage_backdrop()
			_:
				_draw_city_backdrop()
		_draw_road()
		_draw_foreground_dressing()
		return

	_draw_production_outskirts_base()
	_draw_production_outskirts_landmark()
	_draw_production_outskirts_road()
	_draw_production_outskirts_foreground()

func _ensure_production_textures() -> void:
	if _outskirts_sky_far == null:
		_outskirts_sky_far = ProductionArtScript.texture_from_svg(OUTSKIRTS_SKY_FAR_PATH)
	if _outskirts_midground == null:
		_outskirts_midground = ProductionArtScript.texture_from_svg(OUTSKIRTS_MIDGROUND_PATH)
	if _outskirts_road == null:
		_outskirts_road = ProductionArtScript.texture_from_svg(OUTSKIRTS_ROAD_PATH)
	if _outskirts_foreground == null:
		_outskirts_foreground = ProductionArtScript.texture_from_svg(OUTSKIRTS_FOREGROUND_PATH)
	for mission_id in OUTSKIRTS_LANDMARK_PATHS:
		if not _outskirts_landmarks.has(mission_id):
			_outskirts_landmarks[mission_id] = ProductionArtScript.texture_from_svg(
				str(OUTSKIRTS_LANDMARK_PATHS[mission_id])
			)
	if _suburbs_sky_far == null:
		_suburbs_sky_far = ProductionArtScript.texture_from_svg(SUBURBS_SKY_FAR_PATH)
	if _suburbs_midground == null:
		_suburbs_midground = ProductionArtScript.texture_from_svg(SUBURBS_MIDGROUND_PATH)
	if _suburbs_road == null:
		_suburbs_road = ProductionArtScript.texture_from_svg(SUBURBS_ROAD_PATH)
	if _suburbs_foreground == null:
		_suburbs_foreground = ProductionArtScript.texture_from_svg(SUBURBS_FOREGROUND_PATH)
	for mission_id in SUBURBS_LANDMARK_PATHS:
		if not _suburbs_landmarks.has(mission_id):
			_suburbs_landmarks[mission_id] = ProductionArtScript.texture_from_svg(
				str(SUBURBS_LANDMARK_PATHS[mission_id])
			)


func _has_complete_suburbs_set() -> bool:
	return (
		_suburbs_sky_far != null
		and _suburbs_midground != null
		and _suburbs_road != null
		and _suburbs_foreground != null
	)

func _draw_production_suburbs() -> void:
	draw_texture_rect(_suburbs_sky_far, Rect2(0, 0, WORLD_WIDTH, ROAD_TOP), false)
	draw_texture_rect(_suburbs_midground, Rect2(0, 0, WORLD_WIDTH, ROAD_TOP), false)

	var landmark := _suburbs_landmarks.get(_mission_id) as Texture2D
	if landmark != null:
		draw_texture_rect(landmark, Rect2(0, 0, WORLD_WIDTH, ROAD_TOP), false)

	draw_texture_rect(
		_suburbs_road,
		Rect2(0, ROAD_TOP, WORLD_WIDTH, WORLD_HEIGHT - ROAD_TOP),
		false
	)
	draw_texture_rect(
		_suburbs_foreground,
		Rect2(0, ROAD_TOP, WORLD_WIDTH, WORLD_HEIGHT - ROAD_TOP),
		false
	)

func _has_complete_outskirts_set() -> bool:
	return (
		_outskirts_sky_far != null
		and _outskirts_midground != null
		and _outskirts_road != null
		and _outskirts_foreground != null
	)

func _draw_production_outskirts_base() -> void:
	draw_texture_rect(_outskirts_sky_far, Rect2(0, 0, WORLD_WIDTH, ROAD_TOP), false)
	draw_texture_rect(_outskirts_midground, Rect2(0, 0, WORLD_WIDTH, ROAD_TOP), false)

func _draw_production_outskirts_landmark() -> void:
	var landmark := _outskirts_landmarks.get(_mission_id) as Texture2D
	if landmark != null:
		draw_texture_rect(landmark, Rect2(0, 0, WORLD_WIDTH, ROAD_TOP), false)

func _draw_production_outskirts_road() -> void:
	draw_texture_rect(
		_outskirts_road,
		Rect2(0, ROAD_TOP, WORLD_WIDTH, WORLD_HEIGHT - ROAD_TOP),
		false
	)

func _draw_production_outskirts_foreground() -> void:
	# Decorative only: no collision and intentionally concentrated below the
	# aiming corridor, matching the approved secondary-reference foreground.
	draw_texture_rect(
		_outskirts_foreground,
		Rect2(0, ROAD_TOP, WORLD_WIDTH, WORLD_HEIGHT - ROAD_TOP),
		false
	)

func _draw_atmosphere() -> void:
	# Locked visual reference: warm cinematic horizon with cooler upper atmosphere.
	draw_rect(Rect2(0, 0, WORLD_WIDTH, WORLD_HEIGHT), Color("6f8792"))
	draw_rect(Rect2(0, 0, WORLD_WIDTH, 220), Color("517286"))
	draw_rect(Rect2(0, 220, WORLD_WIDTH, 210), Color("9b7767"))
	draw_rect(Rect2(0, 430, WORLD_WIDTH, 255), Color("c7784b"))
	draw_rect(Rect2(0, 610, WORLD_WIDTH, 320), Color("8d6b54"))
	draw_circle(Vector2(1780, 204), 100.0, Color("f4c56c", 0.68))
	draw_circle(Vector2(1780, 204), 146.0, Color("ed9a53", 0.10))
	for y in [330.0, 430.0, 540.0]:
		draw_line(Vector2(0, y), Vector2(WORLD_WIDTH, y + 24.0), Color("f2d4ad", 0.09), 34.0)

func _draw_far_outskirts() -> void:
	# Two non-colliding silhouette layers create 2.5D depth while gameplay stays 2D.
	for rect in [
		Rect2(0, 540, 260, 390),
		Rect2(300, 590, 170, 340),
		Rect2(510, 500, 250, 430),
		Rect2(810, 570, 190, 360),
		Rect2(1030, 480, 310, 450),
		Rect2(1390, 560, 220, 370),
		Rect2(1660, 520, 210, 410),
		Rect2(1910, 575, 250, 355),
	]:
		draw_rect(rect, Color("53636a"))
	for rect in [
		Rect2(45, 650, 190, 280),
		Rect2(265, 700, 150, 230),
		Rect2(465, 625, 200, 305),
		Rect2(735, 680, 180, 250),
		Rect2(990, 640, 210, 290),
		Rect2(1260, 690, 150, 240),
		Rect2(1510, 625, 240, 305),
		Rect2(1810, 680, 220, 250),
	]:
		draw_rect(rect, Color("44545a"))

	# Utility poles repeat across the campaign and become a recognisable Outskirts motif.
	for x in range(140, 2140, 390):
		draw_line(Vector2(x, 585), Vector2(x, 905), Color("34413c"), 10.0)
		draw_line(Vector2(x - 54, 626), Vector2(x + 54, 626), Color("34413c"), 8.0)
		draw_line(Vector2(x - 44, 626), Vector2(x - 18, 688), Color("2d3834"), 3.0)
		draw_line(Vector2(x + 44, 626), Vector2(x + 18, 688), Color("2d3834"), 3.0)
		draw_circle(Vector2(x - 42, 625), 6.0, Color("a8a58c"))
		draw_circle(Vector2(x + 42, 625), 6.0, Color("a8a58c"))

func _draw_city_backdrop() -> void:
	# Abandoned roadside commercial strip with readable rooflines and painted remnants.
	for x in range(80, 2100, 320):
		draw_rect(Rect2(x, 745, 235, 185), Color("3f4c47"))
		draw_rect(Rect2(x + 16, 768, 203, 22), Color("6a5b47"))
		draw_rect(Rect2(x + 28, 814, 58, 116), Color("29332f"))
		draw_rect(Rect2(x + 116, 812, 82, 48), Color("51645f"))
		draw_line(Vector2(x + 116, 870), Vector2(x + 196, 870), Color("a45f42"), 8.0)
		if int(x / 320) % 2 == 0:
			draw_rect(Rect2(x + 132, 724, 58, 18), Color("d4aa55", 0.52))

func _draw_overpass_backdrop() -> void:
	# Broken flyover has thick authored silhouettes but no extra physics.
	draw_rect(Rect2(1120, 612, 1040, 78), Color("3f4945"))
	draw_rect(Rect2(1120, 612, 1040, 16), Color("777d72"))
	draw_rect(Rect2(1325, 686, 84, 244), Color("35403b"))
	draw_rect(Rect2(1855, 686, 84, 244), Color("35403b"))
	draw_polygon(
		PackedVector2Array([
			Vector2(1120, 612),
			Vector2(1240, 548),
			Vector2(1375, 612),
		]),
		PackedColorArray([Color("4b5550")])
	)
	draw_line(Vector2(1240, 548), Vector2(1196, 510), Color("a45f42"), 10.0)
	draw_line(Vector2(1370, 628), Vector2(1440, 680), Color("272f2c"), 7.0)
	for x in range(60, 1050, 250):
		draw_rect(Rect2(x, 760, 170, 170), Color("424f4a"))
		draw_rect(Rect2(x + 22, 796, 34, 64), Color("29332f"))

func _draw_suburbs_backdrop() -> void:
	# Low residential/commercial edge: repeated roofs, retaining walls and utility clutter.
	for x in range(40, 2110, 300):
		draw_rect(Rect2(x, 770, 242, 160), Color("46534e"))
		draw_polygon(
			PackedVector2Array([
				Vector2(x - 12, 770),
				Vector2(x + 112, 694),
				Vector2(x + 254, 770),
			]),
			PackedColorArray([Color("59635c")])
		)
		draw_rect(Rect2(x + 28, 818, 54, 112), Color("2b3531"))
		draw_rect(Rect2(x + 118, 808, 82, 50), Color("51645f"))
		draw_line(Vector2(x + 122, 870), Vector2(x + 198, 870), Color("8f5540"), 7.0)

	draw_rect(Rect2(0, 900, WORLD_WIDTH, 30), Color("566059"))
	for x in range(90, 2110, 240):
		draw_line(Vector2(x, 900), Vector2(x + 28, 864), Color("303a35"), 8.0)
		draw_line(Vector2(x + 28, 864), Vector2(x + 56, 900), Color("303a35"), 8.0)

	# Broken bus-stop / service shelter silhouettes make the region read differently from Outskirts.
	draw_line(Vector2(1260, 886), Vector2(1260, 742), Color("2d3733"), 10.0)
	draw_line(Vector2(1460, 886), Vector2(1460, 742), Color("2d3733"), 10.0)
	draw_line(Vector2(1248, 748), Vector2(1472, 748), Color("2d3733"), 12.0)
	draw_rect(Rect2(1290, 772, 132, 74), Color("40534e", 0.82))
	draw_line(Vector2(1302, 834), Vector2(1408, 784), Color("77b6bf", 0.22), 5.0)

func _draw_salvage_backdrop() -> void:
	# Stacked stripped shells and crane silhouettes distinguish the depot/scrap route.
	for x in range(60, 2070, 285):
		_draw_scrap_stack(Vector2(x, 892))
	draw_line(Vector2(980, 910), Vector2(980, 560), Color("303a36"), 18.0)
	draw_line(Vector2(980, 572), Vector2(1210, 572), Color("303a36"), 15.0)
	draw_line(Vector2(1184, 574), Vector2(1132, 690), Color("303a36"), 8.0)
	draw_circle(Vector2(1130, 704), 18.0, Color("5b604f"))
	draw_line(Vector2(955, 640), Vector2(820, 760), Color("303a36"), 10.0)

func _draw_scrap_stack(origin: Vector2) -> void:
	for offset in SCRAP_STACK_OFFSETS:
		var p: Vector2 = origin + offset
		draw_rect(Rect2(p.x, p.y - 48, 132, 42), Color("4b5550"))
		draw_circle(Vector2(p.x + 28, p.y - 4), 18.0, Color("252c29"))
		draw_circle(Vector2(p.x + 105, p.y - 4), 18.0, Color("252c29"))
		draw_line(Vector2(p.x + 18, p.y - 42), Vector2(p.x + 112, p.y - 13), Color("85513f"), 6.0)

func _draw_road() -> void:
	draw_rect(Rect2(0, ROAD_TOP, WORLD_WIDTH, WORLD_HEIGHT - ROAD_TOP), Color("252728"))
	draw_rect(Rect2(0, ROAD_TOP, WORLD_WIDTH, 20), Color("756b5b"))
	draw_rect(Rect2(0, ROAD_TOP + 20, WORLD_WIDTH, 22), Color("3c3c38"))
	for x in range(50, 2140, 188):
		draw_rect(Rect2(x, 1118, 106, 10), Color("dca948", 0.72))
	for x in range(30, 2140, 310):
		draw_line(Vector2(x, 1008), Vector2(x + 66, 1028), Color("111820", 0.74), 5.0)
		draw_line(Vector2(x + 64, 1028), Vector2(x + 44, 1066), Color("111820", 0.74), 4.0)
	# Warm edge dust separates the gameplay road from the background without
	# changing any collision or trajectory geometry.
	draw_line(Vector2(0, ROAD_TOP + 44), Vector2(WORLD_WIDTH, ROAD_TOP + 44), Color("c9824f", 0.14), 18.0)

func _draw_foreground_dressing() -> void:
	# Approved secondary-reference treatment: darker near-camera framing creates
	# depth while remaining behind all gameplay actors and projectile visuals.
	for x in range(92, 2140, 255):
		draw_circle(Vector2(x, 918), 15, Color("414b46"))
		draw_circle(Vector2(x + 22, 923), 10, Color("363f3b"))
		if int(x / 255) % 3 == 0:
			draw_line(Vector2(x + 34, 925), Vector2(x + 70, 900), Color("91563c"), 5.0)

	# Near-camera concrete, wreck and scrub silhouettes. Keep these low so the
	# launch subject, trajectory corridor and authored interactives stay clear.
	for x in range(-40, 2180, 360):
		draw_polygon(
			PackedVector2Array([
				Vector2(x, 1280),
				Vector2(x + 18, 1214),
				Vector2(x + 82, 1188),
				Vector2(x + 156, 1202),
				Vector2(x + 214, 1168),
				Vector2(x + 290, 1204),
				Vector2(x + 352, 1280),
			]),
			PackedColorArray([Color("111820", 0.96)])
		)
		draw_line(Vector2(x + 56, 1232), Vector2(x + 116, 1188), Color("684838"), 8.0)
		draw_line(Vector2(x + 222, 1220), Vector2(x + 258, 1176), Color("2e3b35"), 7.0)
		draw_circle(Vector2(x + 286, 1218), 25.0, Color("0c1115"))

	# Small warm accents prevent the foreground from reading as a flat black bar.
	for x in range(150, 2100, 520):
		draw_circle(Vector2(x, 1218), 7.0, Color("c66f3c", 0.48))
