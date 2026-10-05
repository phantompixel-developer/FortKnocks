class_name FortKnocksHubVisual
extends Node2D

const ProductionArtScript := preload("res://game/presentation/production_art.gd")
const COMPACT_TEXTURE_PATH := "res://assets/art/production/vehicles/run_down_compact.svg"
const SEDAN_TEXTURE_PATH := "res://assets/art/production/vehicles/old_sedan.svg"
const PICKUP_TEXTURE_PATH := "res://assets/art/production/vehicles/pickup.svg"
const TECHNICAL_TEXTURE_PATH := "res://assets/art/production/vehicles/improvised_technical.svg"
const HUB_SKY_FAR_PATH := "res://assets/art/production/hub/hub_sky_far.svg"
const HUB_MID_STRUCTURES_PATH := "res://assets/art/production/hub/hub_mid_structures.svg"
const HUB_FOREGROUND_PATH := "res://assets/art/production/hub/hub_foreground.svg"

var _vehicle_textures: Dictionary = {}
var _hub_sky_far: Texture2D
var _hub_mid_structures: Texture2D
var _hub_foreground: Texture2D

var _platform_id := "run_down_compact"
var _module_id := ""
var _campaign_stage := 0

func configure(platform_id: String, module_id := "", completed_missions := 0) -> void:
	_platform_id = platform_id
	_module_id = module_id
	if completed_missions >= 10:
		_campaign_stage = 5
	elif completed_missions >= 8:
		_campaign_stage = 4
	elif completed_missions >= 6:
		_campaign_stage = 3
	elif completed_missions >= 4:
		_campaign_stage = 2
	elif completed_missions >= 2:
		_campaign_stage = 1
	else:
		_campaign_stage = 0
	queue_redraw()

func _draw() -> void:
	_ensure_production_textures()
	if _hub_sky_far != null and _hub_mid_structures != null:
		_draw_production_backdrop()
	else:
		_draw_fallback_backdrop()
	_draw_perimeter()
	_draw_campaign_progress()
	_draw_workshop()
	_draw_active_platform()
	_draw_scrapyard_and_fire()
	_draw_gate_and_watch()
	_draw_production_foreground()

func _ensure_production_textures() -> void:
	for platform_id in ["run_down_compact", "old_sedan", "pickup", "improvised_technical"]:
		if not _vehicle_textures.has(platform_id):
			_vehicle_textures[platform_id] = ProductionArtScript.texture_from_svg(_vehicle_path(platform_id))
	if _hub_sky_far == null:
		_hub_sky_far = ProductionArtScript.texture_from_svg(HUB_SKY_FAR_PATH)
	if _hub_mid_structures == null:
		_hub_mid_structures = ProductionArtScript.texture_from_svg(HUB_MID_STRUCTURES_PATH)
	if _hub_foreground == null:
		_hub_foreground = ProductionArtScript.texture_from_svg(HUB_FOREGROUND_PATH)

func _draw_fallback_backdrop() -> void:
	draw_rect(Rect2(0, 0, 720, 650), Color("5d6f77"))
	draw_rect(Rect2(0, 360, 720, 290), Color("9d6c58"))
	draw_circle(Vector2(588, 214), 72.0, Color("efb25f", 0.7))
	draw_rect(Rect2(0, 650, 720, 630), Color("242829"))

func _draw_production_backdrop() -> void:
	draw_texture_rect(_hub_sky_far, Rect2(0, 0, 720, 1280), false)
	draw_texture_rect(_hub_mid_structures, Rect2(0, 0, 720, 1280), false)

func _draw_production_foreground() -> void:
	# Low near-camera framing only. Dynamic platform, settlement upgrades and
	# navigation remain separate so progression never gets baked into the art.
	if _hub_foreground != null:
		draw_texture_rect(_hub_foreground, Rect2(0, 0, 720, 1280), false)


func _draw_perimeter() -> void:
	# Corrugated fence with mismatched panels and the diagonal knock-mark motif.
	draw_rect(Rect2(28, 598, 664, 58), Color("1f2724"))
	for x in range(36, 688, 46):
		var panel := Color("4f5a54") if int(x / 46) % 2 == 0 else Color("596159")
		draw_rect(Rect2(x, 606, 38, 42), panel)
		draw_line(Vector2(x + 8, 608), Vector2(x + 8, 646), Color("69736b"), 3.0)
	for x in [126.0, 336.0, 548.0]:
		draw_line(Vector2(x, 644), Vector2(x + 30, 608), Color("d4aa55", 0.75), 7.0)
		draw_line(Vector2(x + 20, 644), Vector2(x + 50, 608), Color("a45f42", 0.70), 7.0)

func _draw_campaign_progress() -> void:
	if _campaign_stage >= 1:
		# Organised racks and marked salvage bins replace loose survival clutter.
		draw_rect(Rect2(18, 680, 50, 154), Color("202825"))
		for y in [694.0, 734.0, 774.0]:
			draw_rect(Rect2(24, y, 38, 25), Color("6d6653"))
			draw_line(Vector2(29, y + 4), Vector2(56, y + 20), Color("d4aa55", 0.55), 4.0)
		for offset in [Vector2(318, 900), Vector2(351, 910), Vector2(386, 896)]:
			draw_rect(Rect2(offset, Vector2(28, 25)), Color("655b47"))

	if _campaign_stage >= 2:
		# Generator, permanent work lights and cable runs make the base visibly operational.
		draw_rect(Rect2(276, 848, 96, 60), Color("27312d"))
		draw_rect(Rect2(284, 856, 80, 35), Color("596158"))
		draw_circle(Vector2(295, 914), 13, Color("171c1b"))
		draw_circle(Vector2(352, 914), 13, Color("171c1b"))
		draw_line(Vector2(326, 850), Vector2(326, 814), Color("26312d"), 8.0)
		draw_circle(Vector2(326, 808), 11, Color("d4aa55"))
		draw_circle(Vector2(326, 808), 22, Color("d4aa55", 0.12))
		draw_line(Vector2(626, 604), Vector2(626, 492), Color("28332f"), 10.0)
		draw_line(Vector2(586, 502), Vector2(668, 502), Color("28332f"), 8.0)
		for x in [597.0, 657.0]:
			draw_circle(Vector2(x, 516), 10, Color("d4aa55"))
			draw_circle(Vector2(x, 516), 19, Color("d4aa55", 0.11))

	if _campaign_stage >= 3:
		# Outskirts secured: the improvised camp has become a deliberate defensive site.
		draw_rect(Rect2(28, 584, 664, 17), Color("1c2421"))
		draw_line(Vector2(530, 590), Vector2(530, 414), Color("202a26"), 11.0)
		draw_line(Vector2(530, 430), Vector2(574, 452), Color("202a26"), 6.0)
		draw_line(Vector2(530, 454), Vector2(492, 476), Color("202a26"), 6.0)
		draw_circle(Vector2(530, 410), 9.0, Color("d4aa55"))
		draw_arc(Vector2(530, 410), 28.0, -2.6, -0.5, 18, Color("d4aa55", 0.35), 3.0, true)

	if _campaign_stage >= 4:
		# Suburbs foothold: heavier fabrication equipment appears once technical capability is recovered.
		draw_rect(Rect2(374, 666, 286, 18), Color("202824"))
		draw_line(Vector2(394, 670), Vector2(394, 820), Color("26312d"), 14.0)
		draw_line(Vector2(642, 670), Vector2(642, 820), Color("26312d"), 14.0)
		draw_line(Vector2(410, 700), Vector2(626, 700), Color("6c7369"), 8.0)
		draw_rect(Rect2(468, 706, 96, 28), Color("4f5b55"))
		draw_line(Vector2(480, 730), Vector2(550, 710), Color("d4aa55", 0.52), 5.0)
		draw_circle(Vector2(586, 718), 9.0, Color("77b6bf"))

	if _campaign_stage >= 5:
		# Protected Suburbs supply line: recovered loads now have a deliberate secured storage bay.
		draw_rect(Rect2(18, 846, 164, 18), Color("202824"))
		draw_line(Vector2(30, 850), Vector2(30, 944), Color("26312d"), 10.0)
		draw_line(Vector2(170, 850), Vector2(170, 944), Color("26312d"), 10.0)
		draw_line(Vector2(36, 870), Vector2(164, 870), Color("6b6653"), 7.0)
		for crate in [Rect2(42, 886, 46, 34), Rect2(92, 890, 54, 30), Rect2(64, 923, 62, 28)]:
			draw_rect(crate, Color("655b47"))
			draw_line(crate.position + Vector2(5, 5), crate.end - Vector2(5, 5), Color("d4aa55", 0.42), 4.0)

func _draw_gate_and_watch() -> void:
	var post_color := Color("222b27") if _campaign_stage < 3 else Color("19211e")
	var brace_color := Color("4e5a53") if _campaign_stage < 3 else Color("667168")
	var post_width := 28.0 if _campaign_stage < 3 else 36.0
	draw_rect(Rect2(72, 898, post_width, 178), post_color)
	draw_rect(Rect2(312, 898, post_width, 178), post_color)
	draw_line(Vector2(86, 900), Vector2(326, 900), brace_color, 14.0 if _campaign_stage < 3 else 20.0)
	draw_line(Vector2(94, 936), Vector2(310, 1017), brace_color, 8.0)
	draw_line(Vector2(310, 936), Vector2(94, 1017), brace_color, 8.0)
	# Two slash marks become the base's simple painted identifier.
	draw_line(Vector2(176, 965), Vector2(204, 928), Color("d4aa55"), 9.0)
	draw_line(Vector2(198, 970), Vector2(226, 933), Color("a45f42"), 9.0)

	draw_rect(Rect2(608, 652, 24, 184), Color("222b27"))
	draw_rect(Rect2(574, 642, 92, 20), Color("222b27"))
	draw_rect(Rect2(584, 612, 72, 30), Color("394640"))
	draw_line(Vector2(620, 612), Vector2(620, 566), Color("27312d"), 8.0)
	draw_circle(Vector2(620, 560), 8, Color("687a72"))

func _draw_workshop() -> void:
	draw_rect(Rect2(72, 708, 250, 148), Color("26312d"))
	draw_polygon(
		PackedVector2Array([Vector2(54, 712), Vector2(197, 644), Vector2(344, 712)]),
		PackedColorArray([Color("52656a")])
	)
	draw_line(Vector2(86, 710), Vector2(86, 862), Color("1b231f"), 10.0)
	draw_line(Vector2(307, 710), Vector2(307, 862), Color("1b231f"), 10.0)
	draw_rect(Rect2(104, 776, 188, 18), Color("6b5848"))
	draw_circle(Vector2(198, 742), 46.0, Color("f0a14a", 0.10))
	draw_circle(Vector2(198, 742), 8.0, Color("f0a14a", 0.78))
	for x in [122.0, 168.0, 214.0, 260.0]:
		draw_line(Vector2(x, 782), Vector2(x + 18, 756), Color("d4aa55", 0.45), 4.0)

	if _platform_id == "old_sedan" or _platform_id == "pickup" or _platform_id == "improvised_technical":
		draw_rect(Rect2(348, 680, 318, 20), Color("26312d"))
		draw_line(Vector2(364, 680), Vector2(364, 876), Color("202824"), 13.0)
		draw_line(Vector2(650, 680), Vector2(650, 876), Color("202824"), 13.0)
		draw_rect(Rect2(374, 706, 270, 15), Color("6a7165"))
		draw_line(Vector2(386, 721), Vector2(620, 721), Color("a45f42", 0.42), 4.0)

func _draw_active_platform() -> void:
	var texture := _vehicle_textures.get(_platform_id) as Texture2D
	if texture != null:
		var rect := Rect2(356, 746, 318, 158)
		match _platform_id:
			"old_sedan":
				rect = Rect2(350, 742, 326, 152)
			"pickup":
				rect = Rect2(342, 738, 338, 158)
			"improvised_technical":
				rect = Rect2(328, 724, 362, 170)
		draw_texture_rect(texture, rect, false)
		_draw_production_module_overlay(rect)
		return

	if _platform_id == "improvised_technical":
		_draw_technical()
	elif _platform_id == "pickup":
		_draw_pickup()
	elif _platform_id == "old_sedan":
		_draw_sedan()
	else:
		_draw_compact()

func _draw_compact() -> void:
	draw_rect(Rect2(402, 782, 226, 72), Color("171c1b"))
	draw_rect(Rect2(408, 788, 214, 58), Color("70513f"))
	_draw_hub_wheels(454, 584, 858)



func _vehicle_path(platform_id: String) -> String:
	match platform_id:
		"old_sedan":
			return SEDAN_TEXTURE_PATH
		"pickup":
			return PICKUP_TEXTURE_PATH
		"improvised_technical":
			return TECHNICAL_TEXTURE_PATH
		_:
			return COMPACT_TEXTURE_PATH

func _draw_production_module_overlay(rect: Rect2) -> void:
	if _module_id.is_empty():
		return
	var anchor := rect.position + Vector2(rect.size.x * 0.78, rect.size.y * 0.36)
	match _module_id:
		"spotter_rack":
			draw_line(anchor, anchor + Vector2(0, -48), Color("1a2526"), 8.0)
			draw_line(anchor + Vector2(0, -44), anchor + Vector2(28, -58), Color("1a2526"), 6.0)
			draw_circle(anchor + Vector2(34, -61), 11.0, Color("5d918e"))
			draw_circle(anchor + Vector2(34, -61), 4.0, Color("d3f1eb"))
		"ballast_crates":
			draw_rect(Rect2(anchor.x - 34, anchor.y - 22, 34, 27), Color("6d5d43"))
			draw_rect(Rect2(anchor.x + 5, anchor.y - 17, 31, 22), Color("806c4b"))
		"twin_field_rack":
			draw_rect(Rect2(anchor.x - 27, anchor.y - 52, 22, 50), Color("52605c"))
			draw_rect(Rect2(anchor.x + 6, anchor.y - 52, 22, 50), Color("405b56"))
			draw_circle(anchor + Vector2(-16, -41), 4.0, Color("e7ad3c"))
			draw_circle(anchor + Vector2(17, -41), 4.0, Color("77b6bf"))
		"stabilizer_rig":
			draw_line(anchor + Vector2(-18, 2), anchor + Vector2(-36, 42), Color("65716d"), 7.0)
			draw_line(anchor + Vector2(18, 2), anchor + Vector2(36, 42), Color("65716d"), 7.0)
			draw_line(anchor + Vector2(-44, 42), anchor + Vector2(-27, 42), Color("8a7b5e"), 7.0)
			draw_line(anchor + Vector2(27, 42), anchor + Vector2(44, 42), Color("8a7b5e"), 7.0)

func _draw_pickup() -> void:
	var shell := Color("4d655d")
	draw_rect(Rect2(356, 780, 302, 78), Color("171c1b"))
	draw_rect(Rect2(362, 786, 290, 64), shell)
	draw_polygon(
		PackedVector2Array([Vector2(382, 786), Vector2(421, 733), Vector2(520, 733), Vector2(558, 786)]),
		PackedColorArray([shell.lightened(0.055)])
	)
	draw_rect(Rect2(438, 741, 58, 31), Color("435b56"))
	draw_rect(Rect2(560, 798, 82, 35), shell.darkened(0.12))
	_draw_hub_wheels(416, 606, 862)

	if _module_id == "spotter_rack":
		draw_line(Vector2(586, 795), Vector2(586, 724), Color("202824"), 9.0)
		draw_line(Vector2(586, 730), Vector2(621, 711), Color("202824"), 7.0)
		draw_circle(Vector2(628, 708), 13, Color("6c9589"))
		draw_circle(Vector2(628, 708), 6, Color("b7ddd4"))
	elif _module_id == "ballast_crates":
		draw_rect(Rect2(548, 756, 47, 34), Color("655a43"))
		draw_rect(Rect2(599, 762, 39, 28), Color("77684b"))

func _draw_technical() -> void:
	var shell: Color = Color("4b615a")
	draw_rect(Rect2(340, 776, 326, 84), Color("171c1b"))
	draw_rect(Rect2(346, 782, 314, 70), shell)
	draw_polygon(
		PackedVector2Array([Vector2(366, 782), Vector2(410, 724), Vector2(514, 724), Vector2(556, 782)]),
		PackedColorArray([shell.lightened(0.05)])
	)
	draw_rect(Rect2(430, 734, 62, 31), Color("3f5650"))
	draw_rect(Rect2(562, 793, 86, 41), shell.darkened(0.15))
	draw_line(Vector2(558, 789), Vector2(558, 708), Color("202824"), 8.0)
	draw_line(Vector2(558, 712), Vector2(640, 712), Color("202824"), 8.0)
	draw_line(Vector2(640, 712), Vector2(640, 792), Color("202824"), 8.0)
	_draw_hub_wheels(400, 612, 864)

	if _module_id == "twin_field_rack":
		draw_rect(Rect2(574, 736, 27, 48), Color("27312d"))
		draw_rect(Rect2(608, 736, 27, 48), Color("27312d"))
		draw_circle(Vector2(587, 744), 5.0, Color("d4aa55"))
		draw_circle(Vector2(621, 744), 5.0, Color("77b6bf"))
	elif _module_id == "stabilizer_rig":
		draw_line(Vector2(572, 804), Vector2(592, 844), Color("202824"), 8.0)
		draw_line(Vector2(634, 804), Vector2(614, 844), Color("202824"), 8.0)
		draw_rect(Rect2(580, 842, 28, 7), Color("667168"))
		draw_rect(Rect2(606, 842, 28, 7), Color("667168"))

func _draw_sedan() -> void:
	var shell := Color("56675f")
	draw_rect(Rect2(368, 780, 286, 76), Color("171c1b"))
	draw_rect(Rect2(374, 786, 274, 62), shell)
	draw_polygon(
		PackedVector2Array([Vector2(408, 786), Vector2(454, 733), Vector2(586, 733), Vector2(626, 786)]),
		PackedColorArray([shell.lightened(0.05)])
	)
	draw_rect(Rect2(462, 742, 53, 29), Color("435b56"))
	draw_rect(Rect2(523, 742, 53, 29), Color("4b625d"))
	draw_line(Vector2(519, 736), Vector2(519, 786), Color("202824"), 5.0)
	_draw_hub_wheels(427, 600, 860)
	draw_line(Vector2(388, 804), Vector2(412, 794), Color("d4aa55", 0.65), 5.0)

func _draw_hub_wheels(left_x: float, right_x: float, y: float) -> void:
	for x in [left_x, right_x]:
		draw_circle(Vector2(x, y), 31.0, Color("171c1b"))
		draw_circle(Vector2(x, y), 15.0, Color("606961"))
		draw_circle(Vector2(x, y), 6.0, Color("8a8063"))

func _draw_scrapyard_and_fire() -> void:
	for offset in [Vector2(388, 914), Vector2(422, 928), Vector2(456, 910), Vector2(488, 930)]:
		draw_circle(offset, 24, Color("4d544e"))
		draw_line(offset + Vector2(-14, 8), offset + Vector2(15, -7), Color("85513f"), 5.0)
	draw_circle(Vector2(208, 932), 24, Color("9d5e40", 0.62))
	draw_circle(Vector2(208, 927), 14, Color("d4aa55", 0.88))
	draw_circle(Vector2(208, 922), 7, Color("f1d98b", 0.88))
