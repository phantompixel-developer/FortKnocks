class_name CommandBoardScreen
extends Control

signal mission_selected(mission: MissionDefinition)
signal back_requested

const EncounterCatalogScript := preload("res://game/campaign/encounter_catalog.gd")
const ThemeScript := preload("res://game/presentation/fort_knocks_theme.gd")
const ProductionUIScript := preload("res://game/presentation/production_ui.gd")

const BOARD_W := 720.0
const OUTSKIRTS_H := 854.0
const SUBURBS_H := 668.0
const REGION_GAP := 34.0
const ART_ROOT := "res://assets/art/claude_assets/1_Asset_Kit/04_command_board"

const BOARD_TILES := [
	ART_ROOT + "/art/bg_board_tile_a.png",
	ART_ROOT + "/art/bg_board_tile_b.png",
	ART_ROOT + "/art/bg_board_tile_c.png",
]
const REGION_PHOTOS := {
	"OUTSKIRTS": ART_ROOT + "/art/region_photo_outskirts.png",
	"SUBURBS": ART_ROOT + "/art/region_photo_suburbs.png",
}
const PIN_PATHS := {
	"completed": ART_ROOT + "/png/ui/mission_pin_completed.png",
	"current": ART_ROOT + "/png/ui/mission_pin_current.png",
	"available": ART_ROOT + "/png/ui/mission_pin_available.png",
	"locked": ART_ROOT + "/png/ui/mission_pin_locked.png",
}
const GLOW_PATH := ART_ROOT + "/png/ui/mission_pin_current_glow.png"
const POLAROID_FRAME_PATH := ART_ROOT + "/png/ui/polaroid_frame.png"
const POLAROID_OVERLAY_PATH := ART_ROOT + "/png/ui/polaroid_photo_overlay.png"
const PUSH_PIN_PATH := ART_ROOT + "/png/ui/pushpin_red.png"
const TAPE_PATH := ART_ROOT + "/png/ui/tape_strip.png"
const STRING_PATH := ART_ROOT + "/png/ui/string_red_tile.png"
const STRING_SHADOW_PATH := ART_ROOT + "/png/ui/string_shadow_tile.png"

const OUTSKIRTS_POINTS := PackedVector2Array([
	Vector2(513, 93),
	Vector2(587, 257),
	Vector2(460, 393),
	Vector2(287, 493),
	Vector2(167, 630),
	Vector2(347, 767),
])
const SUBURBS_POINTS := PackedVector2Array([
	Vector2(513, 100),
	Vector2(579, 267),
	Vector2(440, 427),
	Vector2(253, 547),
])

@onready var scroll: ScrollContainer = %Scroll
@onready var board_holder: Control = %BoardHolder
@onready var board: Control = %Board
@onready var salvage_label: Label = %SalvageLabel
@onready var chapter_label: Label = %ChapterLabel
@onready var count_label: Label = %CountLabel
@onready var progress_track: NinePatchRect = %Track
@onready var progress_fill: NinePatchRect = %Fill
@onready var back_button: TextureButton = %BackButton

var _snapshot: Dictionary = {}
var _regions: Array[Dictionary] = []
var _current_pin_y := 0.0
var _suburbs_y := 0.0

func _ready() -> void:
	ThemeScript.apply(self)
	$TopRail/Title.add_theme_color_override("font_color", ThemeScript.HAZARD)
	back_button.pressed.connect(func() -> void:
		_play_ui(&"ui_back")
		back_requested.emit()
	)
	scroll.get_v_scroll_bar().value_changed.connect(_on_scroll_changed)
	resized.connect(_center_board)

func configure(save_snapshot: Dictionary) -> void:
	_snapshot = save_snapshot.duplicate(true)
	var inventory := _snapshot.get("inventory", {}) as Dictionary
	salvage_label.text = "%d" % int(inventory.get("salvage", 0))
	_rebuild()

func _rebuild() -> void:
	for child in board.get_children():
		child.queue_free()

	var missions: Array[MissionDefinition] = EncounterCatalogScript.all()
	var outskirts: Array[MissionDefinition] = []
	var suburbs: Array[MissionDefinition] = []
	for mission in missions:
		if mission.id.begins_with("suburbs_"):
			suburbs.append(mission)
		else:
			outskirts.append(mission)

	_regions.clear()
	_regions.append({
		"name": "OUTSKIRTS",
		"missions": outskirts,
		"points": OUTSKIRTS_POINTS,
		"height": OUTSKIRTS_H,
		"photo": str(REGION_PHOTOS["OUTSKIRTS"]),
		"rotation": -4.0,
		"attachment": "pin",
	})
	_regions.append({
		"name": "SUBURBS",
		"missions": suburbs,
		"points": SUBURBS_POINTS,
		"height": SUBURBS_H,
		"photo": str(REGION_PHOTOS["SUBURBS"]),
		"rotation": 3.0,
		"attachment": "tape",
	})

	var board_height := 74.0
	for region in _regions:
		board_height += float(region["height"]) + REGION_GAP
	board_height += 90.0
	board.custom_minimum_size = Vector2(BOARD_W, board_height)
	board.size = Vector2(BOARD_W, board_height)
	board_holder.custom_minimum_size = Vector2(BOARD_W, board_height)

	_build_background(board_height)

	var y := 74.0
	_suburbs_y = 0.0
	_current_pin_y = 0.0
	for region_index in range(_regions.size()):
		var region: Dictionary = _regions[region_index]
		if region_index == 1:
			_suburbs_y = y
		_build_region(region, y)
		y += float(region["height"]) + REGION_GAP

	if _current_pin_y <= 0.0:
		_current_pin_y = _suburbs_y + SUBURBS_POINTS[SUBURBS_POINTS.size() - 1].y
	_build_chapter_divider(y - 38.0)
	_update_hud()
	_center_board.call_deferred()
	_center_current.call_deferred()

func _build_background(board_height: float) -> void:
	var tile_h := 1440.0
	var tile_count := int(ceil(board_height / tile_h))
	for i in range(tile_count):
		var tile := TextureRect.new()
		tile.texture = ProductionUIScript.texture(str(BOARD_TILES[i % BOARD_TILES.size()]))
		tile.position = Vector2(0.0, float(i) * tile_h)
		tile.size = Vector2(BOARD_W, tile_h)
		tile.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tile.stretch_mode = TextureRect.STRETCH_SCALE
		tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
		board.add_child(tile)
		board.move_child(tile, 0)

func _build_region(region: Dictionary, top: float) -> void:
	var name := str(region["name"])
	var missions: Array = region["missions"]
	var points: PackedVector2Array = region["points"]
	var section_h := float(region["height"])

	_add_polaroid(
		name,
		str(region["photo"]),
		Vector2(192.0, top + 130.0),
		float(region["rotation"]),
		str(region["attachment"])
	)
	_add_route(points, top)

	var campaign := _snapshot.get("campaign", {}) as Dictionary
	var unlocked := campaign.get("unlocked_missions", []) as Array
	var completed := campaign.get("completed_missions", []) as Array
	var current_found := _current_pin_y > 0.0

	for i in range(mini(missions.size(), points.size())):
		var mission := missions[i] as MissionDefinition
		var state := "locked"
		if completed.has(mission.id):
			state = "completed"
		elif unlocked.has(mission.id):
			state = "available" if current_found else "current"
			if not current_found:
				_current_pin_y = top + points[i].y
				current_found = true
		_add_mission_pin(mission, state, mission.campaign_order, top + points[i].y, points[i].x)

	_add_region_decor(name, top, section_h)

func _add_route(points: PackedVector2Array, top: float) -> void:
	if points.size() < 2:
		return
	var local := PackedVector2Array()
	for p in points:
		local.append(Vector2(p.x, top + p.y))

	var shadow := Line2D.new()
	shadow.points = local
	shadow.width = 17.0
	shadow.texture = ProductionUIScript.texture(STRING_SHADOW_PATH)
	shadow.texture_mode = Line2D.LINE_TEXTURE_TILE
	shadow.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	shadow.joint_mode = Line2D.LINE_JOINT_ROUND
	shadow.antialiased = true
	shadow.position = Vector2(3.0, 5.0)
	board.add_child(shadow)

	var line := Line2D.new()
	line.points = local
	line.width = 14.0
	line.texture = ProductionUIScript.texture(STRING_PATH)
	line.texture_mode = Line2D.LINE_TEXTURE_TILE
	line.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	line.antialiased = true
	board.add_child(line)

func _add_polaroid(caption: String, photo_path: String, position: Vector2, angle: float, attachment: String) -> void:
	var root := Control.new()
	root.position = position
	root.size = Vector2(307.0, 280.0)
	root.rotation_degrees = angle
	root.pivot_offset = root.size * 0.5
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var photo := TextureRect.new()
	photo.texture = ProductionUIScript.texture(photo_path)
	photo.position = Vector2(27.0, 23.0)
	photo.size = Vector2(253.0, 167.0)
	photo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	photo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	photo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(photo)

	var overlay := TextureRect.new()
	overlay.texture = ProductionUIScript.texture(POLAROID_OVERLAY_PATH)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(overlay)

	var frame := TextureRect.new()
	frame.texture = ProductionUIScript.texture(POLAROID_FRAME_PATH)
	frame.set_anchors_preset(Control.PRESET_FULL_RECT)
	frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame.stretch_mode = TextureRect.STRETCH_SCALE
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(frame)

	var label := Label.new()
	label.position = Vector2(34.0, 198.0)
	label.size = Vector2(239.0, 52.0)
	label.text = caption
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", Color("1c252a"))
	label.add_theme_font_size_override("font_size", 23)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(label)

	var attach := TextureRect.new()
	attach.texture = ProductionUIScript.texture(PUSH_PIN_PATH if attachment == "pin" else TAPE_PATH)
	attach.position = Vector2(128.0, -12.0) if attachment == "pin" else Vector2(104.0, -2.0)
	attach.size = Vector2(52.0, 52.0) if attachment == "pin" else Vector2(98.0, 34.0)
	attach.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	attach.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	attach.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(attach)

	board.add_child(root)

func _add_mission_pin(mission: MissionDefinition, state: String, number: int, y: float, x: float) -> void:
	var button := Button.new()
	button.position = Vector2(x - 50.0, y - 48.0)
	button.size = Vector2(100.0, 104.0)
	button.flat = true
	button.focus_mode = Control.FOCUS_NONE
	button.tooltip_text = "%02d • %s" % [mission.campaign_order, mission.display_name]
	button.disabled = state == "locked"

	if state == "current":
		var glow := TextureRect.new()
		glow.texture = ProductionUIScript.texture(GLOW_PATH)
		glow.position = Vector2(-10.0, -10.0)
		glow.size = Vector2(120.0, 120.0)
		glow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(glow)
		var pulse := create_tween().set_loops()
		pulse.tween_property(glow, "modulate:a", 0.48, 0.75).set_trans(Tween.TRANS_SINE)
		pulse.tween_property(glow, "modulate:a", 1.0, 0.75).set_trans(Tween.TRANS_SINE)

	var icon := TextureRect.new()
	icon.texture = ProductionUIScript.texture(str(PIN_PATHS[state]))
	icon.position = Vector2(14.0, 8.0)
	icon.size = Vector2(72.0, 72.0)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(icon)

	var label := Label.new()
	label.position = Vector2(18.0, 17.0)
	label.size = Vector2(64.0, 54.0)
	label.text = str(number)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color("f2f4f6") if state != "completed" else Color("172027"))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(label)

	if state != "locked":
		button.pressed.connect(_select_mission.bind(mission))
	board.add_child(button)

func _add_region_decor(name: String, top: float, section_h: float) -> void:
	var decor: Array[Dictionary] = []
	if name == "OUTSKIRTS":
		decor = [
			{"path": ART_ROOT + "/png/decor/decor_coffee_ring.png", "pos": Vector2(596, top + section_h - 120), "size": Vector2(96, 96), "rot": 8.0},
			{"path": ART_ROOT + "/png/decor/decor_marker_arrow.png", "pos": Vector2(92, top + 610), "size": Vector2(86, 72), "rot": -18.0},
			{"path": ART_ROOT + "/png/decor/decor_stain_dirt.png", "pos": Vector2(24, top + 360), "size": Vector2(150, 120), "rot": 0.0},
		]
	else:
		decor = [
			{"path": ART_ROOT + "/png/decor/decor_note_lined.png", "pos": Vector2(486, top + 450), "size": Vector2(150, 112), "rot": -7.0},
			{"path": ART_ROOT + "/png/decor/decor_marker_x.png", "pos": Vector2(82, top + 500), "size": Vector2(74, 70), "rot": 12.0},
			{"path": ART_ROOT + "/png/decor/decor_scrap_torn.png", "pos": Vector2(535, top + 50), "size": Vector2(150, 104), "rot": 4.0},
		]
	for item in decor:
		var tex := TextureRect.new()
		tex.texture = ProductionUIScript.texture(str(item["path"]))
		var decor_position: Vector2 = item["pos"]
		var decor_size: Vector2 = item["size"]
		tex.position = decor_position
		tex.size = decor_size
		tex.rotation_degrees = float(item["rot"])
		tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		board.add_child(tex)

func _build_chapter_divider(y: float) -> void:
	var banner := NinePatchRect.new()
	banner.texture = ProductionUIScript.texture(ART_ROOT + "/png/ui/chapter_banner_9s.png")
	banner.patch_margin_left = 30
	banner.patch_margin_top = 30
	banner.patch_margin_right = 30
	banner.patch_margin_bottom = 30
	banner.position = Vector2(110.0, y)
	banner.size = Vector2(500.0, 74.0)
	banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	board.add_child(banner)

	var label := Label.new()
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.text = "CHAPTER 2 • ROUTE NOT YET OPEN"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 18)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	banner.add_child(label)

func _select_mission(mission: MissionDefinition) -> void:
	_play_ui(&"ui_confirm")
	mission_selected.emit(mission)

func _update_hud() -> void:
	var campaign := _snapshot.get("campaign", {}) as Dictionary
	var completed := campaign.get("completed_missions", []) as Array
	var total := EncounterCatalogScript.all().size()
	count_label.text = "%d/%d" % [mini(completed.size(), total), total]
	chapter_label.text = "CHAPTER 1 • OUTSKIRTS"
	_update_progress_fill.call_deferred()

func _update_progress_fill() -> void:
	var campaign := _snapshot.get("campaign", {}) as Dictionary
	var completed := campaign.get("completed_missions", []) as Array
	var total := maxi(EncounterCatalogScript.all().size(), 1)
	var fraction := clampf(float(completed.size()) / float(total), 0.0, 1.0)
	var inner_width := maxf(progress_track.size.x - 12.0, 0.0)
	progress_fill.visible = fraction > 0.0
	progress_fill.size.x = maxf(inner_width * fraction, 24.0) if fraction > 0.0 else 0.0

func _on_scroll_changed(value: float) -> void:
	chapter_label.text = "CHAPTER 1 • SUBURBS" if value + scroll.size.y * 0.45 >= _suburbs_y else "CHAPTER 1 • OUTSKIRTS"

func _center_current() -> void:
	if _current_pin_y <= 0.0:
		return
	var target := int(maxf(_current_pin_y - scroll.size.y * 0.44, 0.0))
	scroll.scroll_vertical = target

func _center_board() -> void:
	if board_holder == null or board == null:
		return
	board.position.x = maxf((board_holder.size.x - BOARD_W) * 0.5, 0.0)

func _play_ui(cue: StringName) -> void:
	var audio := get_tree().get_first_node_in_group("fort_knocks_audio")
	if audio != null and audio.has_method("play_cue"):
		audio.call("play_cue", cue)
