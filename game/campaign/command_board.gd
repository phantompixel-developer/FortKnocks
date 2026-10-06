class_name CommandBoardScreen
extends Control

signal mission_selected(mission: MissionDefinition)
signal back_requested

const EncounterCatalogScript := preload("res://game/campaign/encounter_catalog.gd")
const ThemeScript := preload("res://game/presentation/fort_knocks_theme.gd")
const ProductionUIScript := preload("res://game/presentation/production_ui.gd")
const BoardBoldFont := preload("res://assets/art/production/hub/reference_v1/fonts/BarlowCondensed-Bold.ttf")

const BOARD_W: float = 720.0
const SCALE: float = 2.0 / 3.0
const TOP_PAD: float = 40.0 * SCALE
const BOTTOM_PAD: float = 140.0 * SCALE
const BANNER_BLOCK: float = 170.0 * SCALE
const ROUTE_W: float = 20.0 * SCALE
const BG_TILE_H: float = 2160.0 * SCALE

const CHAPTER_1_TOTAL: int = 15
const CHAPTER_2_TOTAL: int = 18

static var POLAROID_SIZE: Vector2 = Vector2(460.0, 420.0) * SCALE
static var PIN_SIZE: Vector2 = Vector2(140.0, 140.0) * SCALE
static var PIN_CENTER: Vector2 = Vector2(70.0, 67.0) * SCALE

const BG_TILES: Array[Texture2D] = [
	preload("res://assets/art/claude_assets/1_Asset_Kit/04_command_board/art/bg_board_tile_a.png"),
	preload("res://assets/art/claude_assets/1_Asset_Kit/04_command_board/art/bg_board_tile_b.png"),
	preload("res://assets/art/claude_assets/1_Asset_Kit/04_command_board/art/bg_board_tile_c.png"),
]
const PHOTO_OUTSKIRTS := preload("res://assets/art/claude_assets/1_Asset_Kit/04_command_board/art/region_photo_outskirts.png")
const PHOTO_SUBURBS := preload("res://assets/art/claude_assets/1_Asset_Kit/04_command_board/art/region_photo_suburbs.png")
const PHOTO_HIGHWAY := preload("res://assets/art/claude_assets/1_Asset_Kit/04_command_board/art/region_photo_highway.png")
const PHOTO_INDUSTRIAL := preload("res://assets/art/claude_assets/1_Asset_Kit/04_command_board/art/region_photo_industrial.png")
const PHOTO_BADLANDS := preload("res://assets/art/claude_assets/1_Asset_Kit/04_command_board/art/region_photo_badlands.png")
const PHOTO_CITY := preload("res://assets/art/claude_assets/1_Asset_Kit/04_command_board/art/region_photo_the_city.png")

const ROUTE_TEX := preload("res://assets/art/claude_assets/1_Asset_Kit/04_command_board/png/ui/string_red_tile.png")
const ROUTE_SHADOW_TEX := preload("res://assets/art/claude_assets/1_Asset_Kit/04_command_board/png/ui/string_shadow_tile.png")
const BANNER_TEX := preload("res://assets/art/claude_assets/1_Asset_Kit/04_command_board/png/ui/chapter_banner_9s.png")
const TAPE_TEX := preload("res://assets/art/claude_assets/1_Asset_Kit/04_command_board/png/ui/tape_strip.png")
const POLAROID_FRAME := preload("res://assets/art/claude_assets/1_Asset_Kit/04_command_board/png/ui/polaroid_frame.png")
const POLAROID_OVERLAY := preload("res://assets/art/claude_assets/1_Asset_Kit/04_command_board/png/ui/polaroid_photo_overlay.png")
const PUSH_PIN := preload("res://assets/art/claude_assets/1_Asset_Kit/04_command_board/png/ui/pushpin_red.png")
const PIN_COMPLETED := preload("res://assets/art/claude_assets/1_Asset_Kit/04_command_board/png/ui/mission_pin_completed.png")
const PIN_CURRENT := preload("res://assets/art/claude_assets/1_Asset_Kit/04_command_board/png/ui/mission_pin_current.png")
const PIN_AVAILABLE := preload("res://assets/art/claude_assets/1_Asset_Kit/04_command_board/png/ui/mission_pin_available.png")
const PIN_LOCKED := preload("res://assets/art/claude_assets/1_Asset_Kit/04_command_board/png/ui/mission_pin_locked.png")
const PIN_GLOW := preload("res://assets/art/claude_assets/1_Asset_Kit/04_command_board/png/ui/mission_pin_current_glow.png")
const TAG_PAPER := preload("res://assets/art/claude_assets/1_Asset_Kit/04_command_board/png/ui/tag_paper_9s.png")

const DECOR_TEXTURES := {
	"decor_coffee_ring": preload("res://assets/art/claude_assets/1_Asset_Kit/04_command_board/png/decor/decor_coffee_ring.png"),
	"decor_stain_dirt": preload("res://assets/art/claude_assets/1_Asset_Kit/04_command_board/png/decor/decor_stain_dirt.png"),
	"decor_note_lined": preload("res://assets/art/claude_assets/1_Asset_Kit/04_command_board/png/decor/decor_note_lined.png"),
	"decor_scrap_torn": preload("res://assets/art/claude_assets/1_Asset_Kit/04_command_board/png/decor/decor_scrap_torn.png"),
	"decor_marker_circle": preload("res://assets/art/claude_assets/1_Asset_Kit/04_command_board/png/decor/decor_marker_circle.png"),
	"decor_marker_x": preload("res://assets/art/claude_assets/1_Asset_Kit/04_command_board/png/decor/decor_marker_x.png"),
	"decor_marker_arrow": preload("res://assets/art/claude_assets/1_Asset_Kit/04_command_board/png/decor/decor_marker_arrow.png"),
	"decor_pushpin_blue": preload("res://assets/art/claude_assets/1_Asset_Kit/04_command_board/png/decor/decor_pushpin_blue.png"),
	"decor_pushpin_yellow": preload("res://assets/art/claude_assets/1_Asset_Kit/04_command_board/png/decor/decor_pushpin_yellow.png"),
	"decor_string_loose": preload("res://assets/art/claude_assets/1_Asset_Kit/04_command_board/png/decor/decor_string_loose.png"),
	"tape_strip": preload("res://assets/art/claude_assets/1_Asset_Kit/04_command_board/png/ui/tape_strip.png"),
}

@onready var scroll: ScrollContainer = %Scroll
@onready var board_holder: Control = %BoardHolder
@onready var board: Control = %Board
@onready var back_button: TextureButton = %BackButton
@onready var title_label: Label = %Title
@onready var chapter_label: Label = %ChapterLabel
@onready var count_label: Label = %CountLabel
@onready var progress_track: NinePatchRect = %Track
@onready var progress_fill: NinePatchRect = %Fill
@onready var briefing_overlay: Control = %BriefingOverlay
@onready var briefing_panel: PanelContainer = %BriefingPanel
@onready var briefing_title: Label = %BriefingTitle
@onready var briefing_meta: Label = %BriefingMeta
@onready var briefing_objective: Label = %BriefingObjective
@onready var briefing_text: Label = %BriefingText
@onready var briefing_reward: Label = %BriefingReward
@onready var briefing_close: TextureButton = %BriefingClose
@onready var deploy_button: Button = %DeployButton

var _snapshot: Dictionary = {}
var _pin_buttons: Array[Button] = []
var _pin_missions: Array[MissionDefinition] = []
var _chapter_ranges: Array[Dictionary] = []
var _current_pin: Button
var _focus_pin: Button
var _current_route_index: int = 0
var _board_h: float = 0.0
var _briefing_mission: MissionDefinition

func _ready() -> void:
	ThemeScript.apply(self)
	_style_board_text()

	briefing_panel.add_theme_stylebox_override(
		"panel",
		ProductionUIScript.texture_box(
			"res://assets/art/claude_assets/1_Asset_Kit/00_shared/png/ui/panel_stats_9s.png",
			Vector4(40.0, 40.0, 40.0, 40.0)
		)
	)
	ProductionUIScript.style_action_button(deploy_button)

	back_button.pressed.connect(_on_back)
	briefing_close.pressed.connect(_close_briefing)
	deploy_button.pressed.connect(_deploy_briefing_mission)
	scroll.get_v_scroll_bar().value_changed.connect(func(_value: float) -> void:
		_update_hud()
	)
	scroll.resized.connect(_center_board)
	_apply_safe_area()

func configure(save_snapshot: Dictionary) -> void:
	_snapshot = save_snapshot.duplicate(true)
	_build()

func _build() -> void:
	for child in board.get_children():
		child.queue_free()

	_pin_buttons.clear()
	_pin_missions.clear()
	_chapter_ranges.clear()
	_current_pin = null
	_focus_pin = null
	_current_route_index = 0

	var all_missions: Array[MissionDefinition] = EncounterCatalogScript.all()
	var outskirts: Array[MissionDefinition] = []
	var suburbs: Array[MissionDefinition] = []
	for mission in all_missions:
		if mission.id.begins_with("suburbs_"):
			suburbs.append(mission)
		else:
			outskirts.append(mission)

	var campaign: Dictionary = _snapshot.get("campaign", {}) as Dictionary
	var unlocked: Array = campaign.get("unlocked_missions", []) as Array
	var completed: Array = campaign.get("completed_missions", []) as Array

	var background := Control.new()
	background.name = "Background"
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var decor_under := Control.new()
	decor_under.name = "DecorUnder"
	decor_under.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var polaroids := Control.new()
	polaroids.name = "Polaroids"
	polaroids.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var decor_over := Control.new()
	decor_over.name = "DecorOver"
	decor_over.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var banners := Control.new()
	banners.name = "Banners"
	banners.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var route_layer := Node2D.new()
	route_layer.name = "Route"

	var pins_layer := Control.new()
	pins_layer.name = "Pins"
	pins_layer.mouse_filter = Control.MOUSE_FILTER_PASS

	for layer in [background, decor_under, polaroids, decor_over, banners, route_layer, pins_layer]:
		board.add_child(layer)

	var route_points := PackedVector2Array()
	var y: float = TOP_PAD

	# Chapter 1: the real game currently occupies Outskirts + Suburbs.
	# Highway remains visibly present as the locked continuation so the board
	# retains the authored 15-mission chapter structure from the approved preview.
	var ch1_y0: float = y
	_add_chapter_banner(banners, 1, y)
	y += BANNER_BLOCK

	_add_live_region(
		polaroids, decor_under, decor_over, pins_layer,
		"OUTSKIRTS", PHOTO_OUTSKIRTS, outskirts,
		_layout6_points(), _layout6_decor(),
		1280.0 * SCALE, Vector2(300.0, 250.0), -4.0, false, 0,
		y, unlocked, completed, route_points
	)
	y += 1280.0 * SCALE

	_add_live_region(
		polaroids, decor_under, decor_over, pins_layer,
		"SUBURBS", PHOTO_SUBURBS, suburbs,
		_layout4_points(), _layout4_decor(),
		1000.0 * SCALE, Vector2(290.0, 250.0), -4.0, true, 0,
		y, unlocked, completed, route_points
	)
	y += 1000.0 * SCALE

	_add_locked_region(
		polaroids, decor_under, decor_over, pins_layer,
		"HIGHWAY", PHOTO_HIGHWAY, 5, 11,
		_layout5_points(), _layout5_decor(),
		1140.0 * SCALE, Vector2(300.0, 255.0), -3.0, false, 1,
		y, route_points
	)
	y += 1140.0 * SCALE

	var ch1_done: int = mini(completed.size(), all_missions.size())
	_chapter_ranges.append({
		"y0": ch1_y0,
		"y1": y,
		"chapter": 1,
		"done": ch1_done,
		"total": CHAPTER_1_TOTAL,
	})

	# Chapter 2 is deliberately visible but entirely locked. This is the authored
	# Industrial -> Badlands -> The City continuation from Claude's source board.
	var ch2_y0: float = y
	_add_chapter_banner(banners, 2, y)
	y += BANNER_BLOCK

	_add_locked_region(
		polaroids, decor_under, decor_over, pins_layer,
		"INDUSTRIAL", PHOTO_INDUSTRIAL, 7, 1,
		_layout7_points(), _layout7_decor(),
		1420.0 * SCALE, Vector2(300.0, 250.0), -3.0, true, 1,
		y, route_points
	)
	y += 1420.0 * SCALE

	_add_locked_region(
		polaroids, decor_under, decor_over, pins_layer,
		"BADLANDS", PHOTO_BADLANDS, 5, 8,
		_layout5_points(), _layout5_decor(),
		1140.0 * SCALE, Vector2(300.0, 255.0), -3.0, false, 1,
		y, route_points
	)
	y += 1140.0 * SCALE

	_add_locked_region(
		polaroids, decor_under, decor_over, pins_layer,
		"THE CITY", PHOTO_CITY, 6, 13,
		_layout6_points(), _layout6_decor(),
		1280.0 * SCALE, Vector2(300.0, 250.0), -4.0, true, 0,
		y, route_points
	)
	y += 1280.0 * SCALE

	_chapter_ranges.append({
		"y0": ch2_y0,
		"y1": y,
		"chapter": 2,
		"done": 0,
		"total": CHAPTER_2_TOTAL,
	})

	_board_h = y + BOTTOM_PAD
	_build_route(route_layer, route_points, _current_route_index)
	_build_background(background)

	board.custom_minimum_size = Vector2(BOARD_W, _board_h)
	board.size = board.custom_minimum_size
	board_holder.custom_minimum_size = Vector2(0.0, _board_h)

	_center_board()
	_update_hud()
	_focus_current.call_deferred()

func _add_live_region(
	polaroid_layer: Control,
	decor_under: Control,
	decor_over: Control,
	pins_layer: Control,
	region_name: String,
	photo: Texture2D,
	missions: Array[MissionDefinition],
	raw_points: PackedVector2Array,
	decor: Array,
	_section_height: float,
	raw_polaroid_position: Vector2,
	polaroid_rotation: float,
	mirrored: bool,
	attachment: int,
	y: float,
	unlocked: Array,
	completed: Array,
	route_points: PackedVector2Array
) -> void:
	for item in decor:
		var target: Control = decor_over if bool(item.get("over", false)) else decor_under
		_add_decor(target, item, y, mirrored)

	var reached: bool = false
	for mission in missions:
		if unlocked.has(mission.id) or completed.has(mission.id):
			reached = true
			break

	var polaroid_center: Vector2 = _scaled_point(raw_polaroid_position, mirrored) + Vector2(0.0, y)
	_add_polaroid(
		polaroid_layer,
		photo,
		region_name,
		polaroid_center,
		-polaroid_rotation if mirrored else polaroid_rotation,
		attachment,
		not reached
	)

	for i in range(missions.size()):
		if i >= raw_points.size():
			break

		var mission: MissionDefinition = missions[i]
		var center: Vector2 = _scaled_point(raw_points[i], mirrored) + Vector2(0.0, y)
		route_points.append(center)

		var state := "locked"
		if completed.has(mission.id):
			state = "completed"
		elif unlocked.has(mission.id):
			state = "current" if _current_pin == null else "available"

		var pin: Button = _create_mission_pin(mission, state, mission.campaign_order)
		pin.position = center - PIN_CENTER
		pins_layer.add_child(pin)
		_pin_buttons.append(pin)
		_pin_missions.append(mission)

		if state == "completed":
			_focus_pin = pin
			_current_route_index = route_points.size() - 1
		elif state == "current":
			_current_pin = pin
			_focus_pin = pin
			_current_route_index = route_points.size() - 1
		elif state == "available" and _focus_pin == null:
			_focus_pin = pin

func _add_locked_region(
	polaroid_layer: Control,
	decor_under: Control,
	decor_over: Control,
	pins_layer: Control,
	region_name: String,
	photo: Texture2D,
	slot_count: int,
	first_number: int,
	raw_points: PackedVector2Array,
	decor: Array,
	_section_height: float,
	raw_polaroid_position: Vector2,
	polaroid_rotation: float,
	mirrored: bool,
	attachment: int,
	y: float,
	route_points: PackedVector2Array
) -> void:
	for item in decor:
		var target: Control = decor_over if bool(item.get("over", false)) else decor_under
		_add_decor(target, item, y, mirrored)

	var polaroid_center: Vector2 = _scaled_point(raw_polaroid_position, mirrored) + Vector2(0.0, y)
	_add_polaroid(
		polaroid_layer,
		photo,
		region_name,
		polaroid_center,
		-polaroid_rotation if mirrored else polaroid_rotation,
		attachment,
		true
	)

	for i in range(mini(slot_count, raw_points.size())):
		var center: Vector2 = _scaled_point(raw_points[i], mirrored) + Vector2(0.0, y)
		route_points.append(center)

		var pin: Button = _create_locked_slot(first_number + i)
		pin.position = center - PIN_CENTER
		pins_layer.add_child(pin)
		_pin_buttons.append(pin)

func _create_mission_pin(mission: MissionDefinition, state: String, number: int) -> Button:
	var button: Button = _create_pin_base(state, number)
	button.tooltip_text = mission.display_name

	if state == "locked":
		button.pressed.connect(_shake_pin.bind(button))
	else:
		button.pressed.connect(_open_briefing.bind(mission))

	if state == "current":
		_start_pin_pulse(button)

	return button

func _create_locked_slot(number: int) -> Button:
	var button: Button = _create_pin_base("locked", number)
	button.tooltip_text = "Locked"
	button.pressed.connect(_shake_pin.bind(button))
	return button

func _create_pin_base(state: String, number: int) -> Button:
	var button := Button.new()
	button.custom_minimum_size = PIN_SIZE
	button.size = PIN_SIZE
	button.focus_mode = Control.FOCUS_NONE
	button.flat = true
	button.mouse_filter = Control.MOUSE_FILTER_STOP

	var glow := TextureRect.new()
	glow.name = "_Glow"
	glow.visible = state == "current"
	glow.position = Vector2(-20.0, -23.0) * SCALE
	glow.size = Vector2(180.0, 180.0) * SCALE
	glow.texture = PIN_GLOW
	glow.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	glow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(glow)

	var icon := TextureRect.new()
	icon.name = "_Icon"
	icon.position = Vector2(16.0, 16.0) * SCALE
	icon.size = Vector2(108.0, 108.0) * SCALE
	match state:
		"completed":
			icon.texture = PIN_COMPLETED
		"current":
			icon.texture = PIN_CURRENT
		"available":
			icon.texture = PIN_AVAILABLE
		_:
			icon.texture = PIN_LOCKED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(icon)

	var tag := NinePatchRect.new()
	tag.position = Vector2(40.0, 104.0) * SCALE
	tag.size = Vector2(60.0, 36.0) * SCALE
	tag.texture = TAG_PAPER
	tag.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	tag.patch_margin_left = 8
	tag.patch_margin_top = 8
	tag.patch_margin_right = 8
	tag.patch_margin_bottom = 8
	tag.modulate.a = 0.75 if state == "locked" else 1.0
	tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(tag)

	var label := Label.new()
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.offset_top = -1.333
	label.offset_bottom = -2.667
	label.text = str(number)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", BoardBoldFont)
	label.add_theme_color_override("font_color", Color(0.227, 0.173, 0.11, 1))
	label.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
	label.add_theme_font_size_override("font_size", 16)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tag.add_child(label)

	return button

func _start_pin_pulse(button: Button) -> void:
	var glow: TextureRect = button.get_node("_Glow") as TextureRect
	glow.pivot_offset = glow.size * 0.5
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(glow, "scale", Vector2(1.15, 1.15), 0.7).set_trans(Tween.TRANS_SINE)
	pulse.parallel().tween_property(glow, "modulate:a", 0.55, 0.7).set_trans(Tween.TRANS_SINE)
	pulse.tween_property(glow, "scale", Vector2(0.9, 0.9), 0.7).set_trans(Tween.TRANS_SINE)
	pulse.parallel().tween_property(glow, "modulate:a", 1.0, 0.7).set_trans(Tween.TRANS_SINE)

func _shake_pin(pin: Button) -> void:
	_play_ui(&"ui_back")
	var icon: TextureRect = pin.get_node("_Icon") as TextureRect
	var start_x: float = icon.position.x
	var tween: Tween = create_tween()
	for delta in [6.667, -5.333, 4.0, -2.667, 0.0]:
		tween.tween_property(icon, "position:x", start_x + float(delta), 0.05)

func _add_polaroid(
	parent: Control,
	photo: Texture2D,
	caption: String,
	center: Vector2,
	rotation_degrees_value: float,
	attachment: int,
	dimmed: bool
) -> void:
	var root := Control.new()
	root.size = POLAROID_SIZE
	root.position = center - root.size * 0.5
	root.pivot_offset = root.size * 0.5
	root.rotation_degrees = rotation_degrees_value
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var frame := TextureRect.new()
	frame.size = root.size
	frame.texture = POLAROID_FRAME
	frame.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(frame)

	var photo_rect := TextureRect.new()
	photo_rect.position = Vector2(40.0, 34.0) * SCALE
	photo_rect.size = Vector2(380.0, 250.0) * SCALE
	photo_rect.texture = photo
	photo_rect.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	photo_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	photo_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	photo_rect.self_modulate = Color(0.55, 0.55, 0.60, 1.0) if dimmed else Color.WHITE
	photo_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(photo_rect)

	var overlay := TextureRect.new()
	overlay.position = Vector2(40.0, 34.0) * SCALE
	overlay.size = Vector2(380.0, 250.0) * SCALE
	overlay.texture = POLAROID_OVERLAY
	overlay.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	overlay.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(overlay)

	var label := Label.new()
	label.position = Vector2(30.0, 292.0) * SCALE
	label.size = Vector2(400.0, 94.0) * SCALE
	label.text = caption
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	label.add_theme_font_override("font", BoardBoldFont)
	label.add_theme_color_override("font_color", Color(0.106, 0.086, 0.063, 1))
	label.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
	label.add_theme_font_size_override("font_size", 27)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(label)

	var attach := TextureRect.new()
	if attachment == 0:
		attach.texture = PUSH_PIN
		attach.position = Vector2(194.0, -26.0) * SCALE
		attach.size = Vector2(72.0, 80.0) * SCALE
	else:
		attach.texture = TAPE_TEX
		attach.position = Vector2(140.0, -22.0) * SCALE
		attach.size = Vector2(200.0, 70.0) * SCALE
		attach.rotation = -0.05
	attach.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	attach.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	attach.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	attach.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(attach)

	parent.add_child(root)

func _add_chapter_banner(parent: Control, chapter_number: int, y: float) -> void:
	var banner := NinePatchRect.new()
	banner.texture = BANNER_TEX
	banner.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	banner.patch_margin_left = 20
	banner.patch_margin_top = 20
	banner.patch_margin_right = 20
	banner.patch_margin_bottom = 20
	banner.size = Vector2(520.0, 96.0) * SCALE
	banner.position = Vector2((BOARD_W - banner.size.x) * 0.5, y + 34.0 * SCALE)
	banner.pivot_offset = banner.size * 0.5
	banner.rotation_degrees = -1.5 if chapter_number % 2 == 0 else 1.2
	banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(banner)

	var label := Label.new()
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.offset_top = -2.667
	label.text = "CHAPTER %d" % chapter_number
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", BoardBoldFont)
	label.add_theme_color_override("font_color", Color(0.165, 0.114, 0.071, 1))
	label.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
	label.add_theme_font_size_override("font_size", 24)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	banner.add_child(label)

	for side in [-1, 1]:
		var tape := TextureRect.new()
		tape.texture = TAPE_TEX
		tape.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		tape.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tape.size = TAPE_TEX.get_size()
		tape.scale = Vector2(0.30, 0.30)
		tape.position = Vector2(
			-6.667 if side < 0 else banner.size.x - 53.333,
			4.0
		)
		tape.rotation_degrees = -55.0 * float(side)
		banner.add_child(tape)

func _add_decor(parent: Control, data: Dictionary, y: float, mirrored: bool) -> void:
	var id: String = str(data.get("id", ""))
	var texture: Texture2D = DECOR_TEXTURES.get(id) as Texture2D
	if texture == null:
		return

	var rect := TextureRect.new()
	rect.texture = texture
	rect.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.size = texture.get_size() * SCALE
	rect.pivot_offset = rect.size * 0.5

	var scale_value: float = float(data.get("scale", 1.0))
	rect.scale = Vector2(scale_value, scale_value)

	var raw_position: Vector2 = data.get("pos", Vector2.ZERO)
	var scaled_position: Vector2 = _scaled_point(raw_position, mirrored)
	rect.position = Vector2(scaled_position.x, y + scaled_position.y) - rect.size * 0.5

	var rotation_value: float = float(data.get("rot", 0.0))
	rect.rotation_degrees = -rotation_value if mirrored else rotation_value
	if mirrored and id == "decor_marker_arrow":
		rect.flip_h = true

	parent.add_child(rect)

func _build_route(parent: Node2D, points: PackedVector2Array, current_index: int) -> void:
	if points.size() < 2:
		return

	var smooth: PackedVector2Array = _catmull(points, 16)
	var split: int = clampi(current_index * 16, 0, smooth.size() - 1)
	var travelled: PackedVector2Array = smooth.slice(0, split + 1)
	var future: PackedVector2Array = smooth.slice(split)

	_add_route_part(parent, travelled, 1.0)
	_add_route_part(parent, future, 0.50)

func _add_route_part(parent: Node2D, points: PackedVector2Array, alpha: float) -> void:
	if points.size() < 2:
		return

	var shadow: Line2D = _line(points, ROUTE_SHADOW_TEX, ROUTE_W + 2.667)
	shadow.position = Vector2(2.0, 3.333)
	shadow.modulate.a = alpha
	parent.add_child(shadow)

	var line: Line2D = _line(points, ROUTE_TEX, ROUTE_W)
	line.modulate.a = alpha
	parent.add_child(line)

func _line(points: PackedVector2Array, texture: Texture2D, width: float) -> Line2D:
	var line := Line2D.new()
	line.points = points
	line.width = width
	line.texture = texture
	line.texture_mode = Line2D.LINE_TEXTURE_TILE
	line.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	line.antialiased = true
	return line

func _catmull(points: PackedVector2Array, samples: int) -> PackedVector2Array:
	var output := PackedVector2Array()
	var padded := PackedVector2Array([points[0]])
	padded.append_array(points)
	padded.append(points[points.size() - 1])

	for i in range(1, padded.size() - 2):
		for sample in range(samples):
			var t: float = float(sample) / float(samples)
			var t2: float = t * t
			var t3: float = t2 * t
			output.append(
				0.5 * (
					(2.0 * padded[i])
					+ (-padded[i - 1] + padded[i + 1]) * t
					+ (2.0 * padded[i - 1] - 5.0 * padded[i] + 4.0 * padded[i + 1] - padded[i + 2]) * t2
					+ (-padded[i - 1] + 3.0 * padded[i] - 3.0 * padded[i + 1] + padded[i + 2]) * t3
				)
			)

	output.append(points[points.size() - 1])
	return output

func _build_background(parent: Control) -> void:
	var tile_count: int = int(ceil(_board_h / BG_TILE_H))
	for i in range(tile_count):
		var tile := TextureRect.new()
		tile.texture = BG_TILES[i % BG_TILES.size()]
		tile.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		tile.position = Vector2(0.0, float(i) * BG_TILE_H)
		tile.size = Vector2(BOARD_W, BG_TILE_H)
		tile.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tile.stretch_mode = TextureRect.STRETCH_SCALE
		tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
		parent.add_child(tile)

func _open_briefing(mission: MissionDefinition) -> void:
	if mission == null:
		return

	_play_ui(&"ui_confirm")
	_briefing_mission = mission
	briefing_title.text = mission.display_name.to_upper()
	briefing_meta.text = "MISSION %02d  •  %s" % [
		mission.campaign_order,
		"SUBURBS" if mission.id.begins_with("suburbs_") else "OUTSKIRTS",
	]
	briefing_objective.text = mission.objective_text.to_upper()
	briefing_text.text = mission.briefing
	briefing_reward.text = "RECOVERY  •  %d SALVAGE" % mission.salvage_reward
	briefing_overlay.visible = true
	briefing_overlay.modulate.a = 0.0
	briefing_panel.pivot_offset = briefing_panel.size * 0.5
	briefing_panel.scale = Vector2(0.96, 0.96)

	var tween: Tween = create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(briefing_overlay, "modulate:a", 1.0, 0.14)
	tween.tween_property(briefing_panel, "scale", Vector2.ONE, 0.18)

func _close_briefing() -> void:
	if not briefing_overlay.visible:
		return
	_play_ui(&"ui_back")
	briefing_overlay.visible = false
	_briefing_mission = null

func _deploy_briefing_mission() -> void:
	if _briefing_mission == null:
		return
	var mission: MissionDefinition = _briefing_mission
	briefing_overlay.visible = false
	_briefing_mission = null
	mission_selected.emit(mission)

func _on_back() -> void:
	if briefing_overlay.visible:
		_close_briefing()
	else:
		_play_ui(&"ui_back")
		back_requested.emit()

func _focus_current() -> void:
	await get_tree().process_frame
	await get_tree().process_frame

	if _focus_pin != null:
		var target: int = int(_focus_pin.position.y + PIN_CENTER.y - scroll.size.y * 0.5)
		scroll.scroll_vertical = maxi(target, 0)
	_update_hud()

func _update_hud() -> void:
	if _chapter_ranges.is_empty():
		return

	var center: float = float(scroll.scroll_vertical) + scroll.size.y * 0.5
	var range_data: Dictionary = _chapter_ranges[0]
	for candidate in _chapter_ranges:
		if center >= float(candidate.get("y0", 0.0)):
			range_data = candidate

	var chapter_number: int = int(range_data.get("chapter", 1))
	var done: int = int(range_data.get("done", 0))
	var total: int = maxi(int(range_data.get("total", 1)), 1)

	chapter_label.text = "CHAPTER %d" % chapter_number
	count_label.text = "%d/%d" % [done, total]

	var fraction: float = clampf(float(done) / float(total), 0.0, 1.0)
	var inner_width: float = maxf(progress_track.size.x - 8.0, 0.0)
	progress_fill.visible = fraction > 0.0
	progress_fill.size = Vector2(
		maxf(inner_width * fraction, 24.0) if fraction > 0.0 else 0.0,
		maxf(progress_track.size.y - 8.0, 0.0)
	)

func _center_board() -> void:
	board.position.x = maxf((board_holder.size.x - BOARD_W) * 0.5, 0.0)

func _style_board_text() -> void:
	for label in [
		title_label,
		chapter_label,
		count_label,
		briefing_title,
		briefing_meta,
		briefing_objective,
		briefing_reward,
	]:
		label.add_theme_font_override("font", BoardBoldFont)

	title_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.42))
	chapter_label.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
	count_label.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)

func _apply_safe_area() -> void:
	var window_size: Vector2i = DisplayServer.window_get_size()
	if window_size.y <= 0:
		return

	var safe_rect: Rect2i = DisplayServer.get_display_safe_area()
	if safe_rect.size.y <= 0:
		return

	var viewport_size: Vector2 = get_viewport_rect().size
	var top_inset: float = float(safe_rect.position.y) * (viewport_size.y / float(window_size.y))
	var bottom_inset: float = float(window_size.y - (safe_rect.position.y + safe_rect.size.y)) * (
		viewport_size.y / float(window_size.y)
	)

	if top_inset > 0.0 and top_inset < 160.0:
		%TopRail.offset_bottom += top_inset
		%TopContent.offset_top += top_inset
		%TopContent.offset_bottom += top_inset
		scroll.offset_top += top_inset
		%EdgeTop.offset_top += top_inset
		%EdgeTop.offset_bottom += top_inset

	if bottom_inset > 0.0 and bottom_inset < 160.0:
		%Hud.offset_top -= bottom_inset
		%Hud.offset_bottom -= bottom_inset
		scroll.offset_bottom -= bottom_inset
		%EdgeBottom.offset_top -= bottom_inset
		%EdgeBottom.offset_bottom -= bottom_inset

func _scaled_point(raw_point: Vector2, mirrored: bool) -> Vector2:
	var point: Vector2 = raw_point
	if mirrored:
		point = Vector2(1080.0 - raw_point.x, raw_point.y)
	return point * SCALE

func _layout4_points() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(770.0, 150.0),
		Vector2(868.0, 400.0),
		Vector2(660.0, 640.0),
		Vector2(380.0, 820.0),
	])

func _layout5_points() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(770.0, 130.0),
		Vector2(880.0, 370.0),
		Vector2(700.0, 600.0),
		Vector2(430.0, 770.0),
		Vector2(240.0, 975.0),
	])

func _layout6_points() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(770.0, 140.0),
		Vector2(880.0, 385.0),
		Vector2(690.0, 590.0),
		Vector2(430.0, 740.0),
		Vector2(250.0, 945.0),
		Vector2(520.0, 1150.0),
	])

func _layout7_points() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(765.0, 130.0),
		Vector2(880.0, 360.0),
		Vector2(705.0, 565.0),
		Vector2(445.0, 705.0),
		Vector2(225.0, 905.0),
		Vector2(430.0, 1110.0),
		Vector2(760.0, 1265.0),
	])

func _layout4_decor() -> Array:
	return [
		{"id": "decor_note_lined", "pos": Vector2(480, 430), "rot": 12.0, "scale": 0.5, "over": false},
		{"id": "decor_marker_circle", "pos": Vector2(660, 642), "rot": -6.0, "scale": 0.48, "over": false},
		{"id": "decor_stain_dirt", "pos": Vector2(520, 960), "rot": 0.0, "scale": 1.0, "over": false},
		{"id": "decor_coffee_ring", "pos": Vector2(880, 760), "rot": 0.0, "scale": 0.8, "over": false},
		{"id": "decor_note_lined", "pos": Vector2(150, 680), "rot": 7.0, "scale": 0.72, "over": false},
		{"id": "decor_pushpin_blue", "pos": Vector2(150, 575), "rot": 0.0, "scale": 1.0, "over": false},
		{"id": "decor_marker_x", "pos": Vector2(948, 585), "rot": 10.0, "scale": 0.6, "over": false},
		{"id": "tape_strip", "pos": Vector2(478, 68), "rot": 38.0, "scale": 0.5, "over": true},
	]

func _layout5_decor() -> Array:
	return [
		{"id": "decor_scrap_torn", "pos": Vector2(90, 470), "rot": -10.0, "scale": 0.65, "over": false},
		{"id": "decor_marker_x", "pos": Vector2(935, 760), "rot": 8.0, "scale": 0.55, "over": false},
		{"id": "decor_string_loose", "pos": Vector2(600, 245), "rot": 6.0, "scale": 0.55, "over": false},
		{"id": "decor_note_lined", "pos": Vector2(130, 1060), "rot": -9.0, "scale": 0.5, "over": false},
		{"id": "decor_scrap_torn", "pos": Vector2(860, 920), "rot": -6.0, "scale": 0.85, "over": false},
		{"id": "decor_pushpin_yellow", "pos": Vector2(850, 838), "rot": 0.0, "scale": 1.0, "over": false},
		{"id": "decor_coffee_ring", "pos": Vector2(130, 650), "rot": 0.0, "scale": 0.6, "over": false},
		{"id": "decor_marker_arrow", "pos": Vector2(590, 470), "rot": 22.0, "scale": 0.55, "over": false},
		{"id": "decor_stain_dirt", "pos": Vector2(700, 1040), "rot": 0.0, "scale": 1.1, "over": false},
	]

func _layout6_decor() -> Array:
	return [
		{"id": "decor_scrap_torn", "pos": Vector2(500, 470), "rot": 7.0, "scale": 0.6, "over": false},
		{"id": "decor_coffee_ring", "pos": Vector2(920, 1170), "rot": 0.0, "scale": 0.6, "over": false},
		{"id": "decor_marker_arrow", "pos": Vector2(360, 1050), "rot": -25.0, "scale": 0.5, "over": false},
		{"id": "decor_pushpin_yellow", "pos": Vector2(520, 400), "rot": 0.0, "scale": 1.0, "over": false},
		{"id": "decor_note_lined", "pos": Vector2(850, 900), "rot": -8.0, "scale": 0.75, "over": false},
		{"id": "decor_pushpin_blue", "pos": Vector2(850, 790), "rot": 0.0, "scale": 1.0, "over": false},
		{"id": "decor_marker_circle", "pos": Vector2(690, 592), "rot": -8.0, "scale": 0.55, "over": false},
		{"id": "decor_string_loose", "pos": Vector2(190, 610), "rot": 4.0, "scale": 0.7, "over": false},
		{"id": "decor_stain_dirt", "pos": Vector2(160, 1180), "rot": 0.0, "scale": 1.0, "over": false},
		{"id": "tape_strip", "pos": Vector2(110, 66), "rot": -32.0, "scale": 0.5, "over": true},
	]

func _layout7_decor() -> Array:
	return [
		{"id": "decor_marker_arrow", "pos": Vector2(600, 430), "rot": 15.0, "scale": 0.5, "over": false},
		{"id": "decor_scrap_torn", "pos": Vector2(960, 245), "rot": -8.0, "scale": 0.5, "over": false},
		{"id": "decor_stain_dirt", "pos": Vector2(300, 600), "rot": 0.0, "scale": 0.9, "over": false},
		{"id": "decor_marker_circle", "pos": Vector2(430, 1112), "rot": 5.0, "scale": 0.48, "over": false},
		{"id": "decor_coffee_ring", "pos": Vector2(900, 1040), "rot": 0.0, "scale": 0.75, "over": false},
		{"id": "decor_scrap_torn", "pos": Vector2(170, 1250), "rot": 8.0, "scale": 0.8, "over": false},
		{"id": "decor_marker_x", "pos": Vector2(945, 650), "rot": -6.0, "scale": 0.6, "over": false},
		{"id": "decor_pushpin_blue", "pos": Vector2(205, 560), "rot": 0.0, "scale": 1.0, "over": false},
		{"id": "decor_note_lined", "pos": Vector2(850, 820), "rot": 6.0, "scale": 0.6, "over": false},
		{"id": "decor_stain_dirt", "pos": Vector2(620, 960), "rot": 0.0, "scale": 0.9, "over": false},
	]

func _play_ui(cue: StringName) -> void:
	var audio := get_tree().get_first_node_in_group("fort_knocks_audio")
	if audio != null and audio.has_method("play_cue"):
		audio.call("play_cue", cue)
