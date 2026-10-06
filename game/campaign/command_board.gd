class_name CommandBoardScreen
extends Control

signal mission_selected(mission: MissionDefinition)
signal back_requested

const EncounterCatalogScript := preload("res://game/campaign/encounter_catalog.gd")
const ThemeScript := preload("res://game/presentation/fort_knocks_theme.gd")
const ProductionUIScript := preload("res://game/presentation/production_ui.gd")
const BoardBoldFont := preload("res://assets/art/production/hub/reference_v1/fonts/BarlowCondensed-Bold.ttf")

const BOARD_W: float = 720.0
const BG_TILE_H: float = 1440.0
const TOP_PAD: float = 42.0
const OUTSKIRTS_H: float = 900.0
const SUBURBS_H: float = 780.0
const CHAPTER_GATE_H: float = 220.0
const BOTTOM_PAD: float = 80.0
const ROUTE_W: float = 12.0
const POLAROID_SIZE := Vector2(307.0, 280.0)

const BG_TILES: Array[Texture2D] = [
	preload("res://assets/art/claude_assets/1_Asset_Kit/04_command_board/art/bg_board_tile_a.png"),
	preload("res://assets/art/claude_assets/1_Asset_Kit/04_command_board/art/bg_board_tile_b.png"),
	preload("res://assets/art/claude_assets/1_Asset_Kit/04_command_board/art/bg_board_tile_c.png"),
]
const OUTSKIRTS_PHOTO := preload("res://assets/art/claude_assets/1_Asset_Kit/04_command_board/art/region_photo_outskirts.png")
const SUBURBS_PHOTO := preload("res://assets/art/claude_assets/1_Asset_Kit/04_command_board/art/region_photo_suburbs.png")
const ROUTE_TEX := preload("res://assets/art/claude_assets/1_Asset_Kit/04_command_board/png/ui/string_red_tile.png")
const ROUTE_SHADOW_TEX := preload("res://assets/art/claude_assets/1_Asset_Kit/04_command_board/png/ui/string_shadow_tile.png")
const WIRE_TEX := preload("res://assets/art/claude_assets/1_Asset_Kit/04_command_board/png/ui/wire_locked_tile.png")
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
const LOCK_ICON := preload("res://assets/art/claude_assets/1_Asset_Kit/00_shared/png/icons/icon_lock.png")

const DECOR_TEXTURES := {
	"coffee": preload("res://assets/art/claude_assets/1_Asset_Kit/04_command_board/png/decor/decor_coffee_ring.png"),
	"stain": preload("res://assets/art/claude_assets/1_Asset_Kit/04_command_board/png/decor/decor_stain_dirt.png"),
	"note": preload("res://assets/art/claude_assets/1_Asset_Kit/04_command_board/png/decor/decor_note_lined.png"),
	"scrap": preload("res://assets/art/claude_assets/1_Asset_Kit/04_command_board/png/decor/decor_scrap_torn.png"),
	"circle": preload("res://assets/art/claude_assets/1_Asset_Kit/04_command_board/png/decor/decor_marker_circle.png"),
	"x": preload("res://assets/art/claude_assets/1_Asset_Kit/04_command_board/png/decor/decor_marker_x.png"),
	"arrow": preload("res://assets/art/claude_assets/1_Asset_Kit/04_command_board/png/decor/decor_marker_arrow.png"),
	"blue_pin": preload("res://assets/art/claude_assets/1_Asset_Kit/04_command_board/png/decor/decor_pushpin_blue.png"),
	"yellow_pin": preload("res://assets/art/claude_assets/1_Asset_Kit/04_command_board/png/decor/decor_pushpin_yellow.png"),
	"loose_string": preload("res://assets/art/claude_assets/1_Asset_Kit/04_command_board/png/decor/decor_string_loose.png"),
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
	_current_pin = null
	_focus_pin = null
	_current_route_index = 0

	var missions: Array[MissionDefinition] = EncounterCatalogScript.all()
	var outskirts: Array[MissionDefinition] = []
	var suburbs: Array[MissionDefinition] = []
	for mission in missions:
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

	var route_layer := Node2D.new()
	route_layer.name = "Route"

	var polaroids := Control.new()
	polaroids.name = "Polaroids"
	polaroids.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var decor_over := Control.new()
	decor_over.name = "DecorOver"
	decor_over.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var gate_layer := Control.new()
	gate_layer.name = "ChapterGate"
	gate_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var pins_layer := Control.new()
	pins_layer.name = "Pins"
	pins_layer.mouse_filter = Control.MOUSE_FILTER_PASS

	for layer in [background, decor_under, route_layer, polaroids, decor_over, gate_layer, pins_layer]:
		board.add_child(layer)

	var route_points := PackedVector2Array()
	var y: float = TOP_PAD

	_add_region(
		polaroids,
		decor_under,
		decor_over,
		pins_layer,
		"OUTSKIRTS",
		OUTSKIRTS_PHOTO,
		outskirts,
		_outskirts_points(),
		_outskirts_decor(),
		Vector2(205.0, 270.0),
		-4.0,
		false,
		y,
		_region_reached(outskirts, unlocked, completed),
		unlocked,
		completed,
		route_points
	)
	y += OUTSKIRTS_H

	_add_region(
		polaroids,
		decor_under,
		decor_over,
		pins_layer,
		"SUBURBS",
		SUBURBS_PHOTO,
		suburbs,
		_suburbs_points(),
		_suburbs_decor(),
		Vector2(515.0, 250.0),
		3.5,
		true,
		y,
		_region_reached(suburbs, unlocked, completed),
		unlocked,
		completed,
		route_points
	)
	y += SUBURBS_H

	_add_chapter_gate(gate_layer, y)
	_board_h = y + CHAPTER_GATE_H + BOTTOM_PAD

	_build_route(route_layer, route_points, _current_route_index)
	_build_background(background)

	board.custom_minimum_size = Vector2(BOARD_W, _board_h)
	board.size = board.custom_minimum_size
	board_holder.custom_minimum_size = Vector2(BOARD_W, _board_h)

	_center_board()
	_update_hud()
	_focus_current.call_deferred()

func _region_reached(missions: Array[MissionDefinition], unlocked: Array, completed: Array) -> bool:
	for mission in missions:
		if unlocked.has(mission.id) or completed.has(mission.id):
			return true
	return false

func _add_region(
	polaroid_layer: Control,
	decor_under: Control,
	decor_over: Control,
	pins_layer: Control,
	region_name: String,
	photo: Texture2D,
	missions: Array[MissionDefinition],
	local_points: PackedVector2Array,
	decor: Array,
	polaroid_center: Vector2,
	polaroid_rotation: float,
	use_tape: bool,
	y: float,
	reached: bool,
	unlocked: Array,
	completed: Array,
	route_points: PackedVector2Array
) -> void:
	for item in decor:
		var target: Control = decor_over if bool(item.get("over", false)) else decor_under
		_add_decor(target, item, y)

	_add_polaroid(
		polaroid_layer,
		photo,
		region_name,
		polaroid_center + Vector2(0.0, y),
		polaroid_rotation,
		use_tape,
		not reached
	)

	var current_claimed: bool = _current_pin != null
	for i in range(mini(missions.size(), local_points.size())):
		var mission: MissionDefinition = missions[i]
		var center: Vector2 = local_points[i] + Vector2(0.0, y)
		route_points.append(center)

		var state := "locked"
		if completed.has(mission.id):
			state = "completed"
		elif unlocked.has(mission.id):
			if not current_claimed:
				state = "current"
				current_claimed = true
			else:
				state = "available"

		var pin: Button = _create_mission_pin(mission, state, mission.campaign_order)
		pin.position = center - Vector2(47.0, 45.0)
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

func _create_mission_pin(mission: MissionDefinition, state: String, number: int) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(94.0, 94.0)
	button.size = Vector2(94.0, 94.0)
	button.focus_mode = Control.FOCUS_NONE
	button.flat = true
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	button.tooltip_text = mission.display_name

	var glow := TextureRect.new()
	glow.name = "_Glow"
	glow.visible = state == "current"
	glow.position = Vector2(-13.0, -14.0)
	glow.size = Vector2(120.0, 120.0)
	glow.texture = PIN_GLOW
	glow.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	glow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(glow)

	var icon := TextureRect.new()
	icon.position = Vector2(11.0, 10.0)
	icon.size = Vector2(72.0, 72.0)
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
	tag.position = Vector2(26.0, 69.0)
	tag.size = Vector2(42.0, 25.0)
	tag.texture = TAG_PAPER
	tag.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	tag.patch_margin_left = 8
	tag.patch_margin_top = 8
	tag.patch_margin_right = 8
	tag.patch_margin_bottom = 8
	tag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(tag)

	var label := Label.new()
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.offset_top = -1.0
	label.offset_bottom = -2.0
	label.text = str(number)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", BoardBoldFont)
	label.add_theme_color_override("font_color", Color(0.227, 0.173, 0.11, 1))
	label.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
	label.add_theme_font_size_override("font_size", 16)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tag.add_child(label)

	if state == "locked":
		button.pressed.connect(_shake_pin.bind(button))
	else:
		button.pressed.connect(_open_briefing.bind(mission))

	if state == "current":
		glow.pivot_offset = glow.size * 0.5
		var pulse: Tween = create_tween().set_loops()
		pulse.tween_property(glow, "scale", Vector2(1.13, 1.13), 0.72).set_trans(Tween.TRANS_SINE)
		pulse.parallel().tween_property(glow, "modulate:a", 0.60, 0.72).set_trans(Tween.TRANS_SINE)
		pulse.tween_property(glow, "scale", Vector2(0.92, 0.92), 0.72).set_trans(Tween.TRANS_SINE)
		pulse.parallel().tween_property(glow, "modulate:a", 1.0, 0.72).set_trans(Tween.TRANS_SINE)

	return button

func _shake_pin(pin: Button) -> void:
	_play_ui(&"ui_back")
	var start_x: float = pin.position.x
	var tween: Tween = create_tween()
	for delta in [7.0, -6.0, 4.0, -3.0, 0.0]:
		tween.tween_property(pin, "position:x", start_x + float(delta), 0.05)

func _add_polaroid(
	parent: Control,
	photo: Texture2D,
	caption: String,
	center: Vector2,
	rotation_degrees_value: float,
	use_tape: bool,
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
	photo_rect.position = Vector2(27.0, 23.0)
	photo_rect.size = Vector2(253.0, 167.0)
	photo_rect.texture = photo
	photo_rect.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	photo_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	photo_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	photo_rect.self_modulate = Color(0.48, 0.50, 0.52, 1.0) if dimmed else Color.WHITE
	photo_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(photo_rect)

	var overlay := TextureRect.new()
	overlay.position = Vector2(27.0, 23.0)
	overlay.size = Vector2(253.0, 167.0)
	overlay.texture = POLAROID_OVERLAY
	overlay.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	overlay.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(overlay)

	var label := Label.new()
	label.position = Vector2(18.0, 194.0)
	label.size = Vector2(271.0, 64.0)
	label.text = caption
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", BoardBoldFont)
	label.add_theme_color_override("font_color", Color(0.106, 0.086, 0.063, 1))
	label.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
	label.add_theme_font_size_override("font_size", 27)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(label)

	var attach := TextureRect.new()
	if use_tape:
		attach.texture = TAPE_TEX
		attach.position = Vector2(88.0, -12.0)
		attach.size = Vector2(132.0, 45.0)
		attach.rotation = -0.05
	else:
		attach.texture = PUSH_PIN
		attach.position = Vector2(129.0, -16.0)
		attach.size = Vector2(48.0, 53.0)
	attach.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	attach.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	attach.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	attach.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(attach)

	parent.add_child(root)

func _add_chapter_gate(parent: Control, y: float) -> void:
	var banner := NinePatchRect.new()
	banner.texture = BANNER_TEX
	banner.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	banner.patch_margin_left = 20
	banner.patch_margin_top = 20
	banner.patch_margin_right = 20
	banner.patch_margin_bottom = 20
	banner.size = Vector2(308.0, 61.0)
	banner.position = Vector2((BOARD_W - banner.size.x) * 0.5, y + 29.0)
	banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(banner)

	var label := Label.new()
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.offset_top = -2.0
	label.text = "CHAPTER 2"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", BoardBoldFont)
	label.add_theme_color_override("font_color", Color(0.165, 0.114, 0.071, 1))
	label.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
	label.add_theme_font_size_override("font_size", 24)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	banner.add_child(label)

	var wire := Line2D.new()
	wire.points = PackedVector2Array([
		Vector2(94.0, y + 129.0),
		Vector2(626.0, y + 129.0),
	])
	wire.width = 12.0
	wire.texture = WIRE_TEX
	wire.texture_mode = Line2D.LINE_TEXTURE_TILE
	wire.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	wire.antialiased = true
	parent.add_child(wire)

	var lock := TextureRect.new()
	lock.texture = LOCK_ICON
	lock.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	lock.position = Vector2(330.0, y + 102.0)
	lock.size = Vector2(60.0, 69.0)
	lock.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	lock.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	lock.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(lock)

	var locked_label := Label.new()
	locked_label.position = Vector2(240.0, y + 164.0)
	locked_label.size = Vector2(240.0, 34.0)
	locked_label.text = "LOCKED"
	locked_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	locked_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	locked_label.add_theme_font_override("font", BoardBoldFont)
	locked_label.add_theme_color_override("font_color", Color(0.36, 0.32, 0.27, 0.88))
	locked_label.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
	locked_label.add_theme_font_size_override("font_size", 18)
	locked_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(locked_label)

func _add_decor(parent: Control, data: Dictionary, y: float) -> void:
	var id: String = str(data.get("id", ""))
	var texture: Texture2D = DECOR_TEXTURES.get(id) as Texture2D
	if texture == null:
		return

	var scale_value: float = float(data.get("scale", 0.45))
	var rect := TextureRect.new()
	rect.texture = texture
	rect.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.size = texture.get_size() * scale_value
	rect.pivot_offset = rect.size * 0.5

	var local_pos: Vector2 = data.get("pos", Vector2.ZERO)
	rect.position = Vector2(local_pos.x, y + local_pos.y) - rect.size * 0.5
	rect.rotation_degrees = float(data.get("rot", 0.0))
	parent.add_child(rect)

func _build_route(parent: Node2D, points: PackedVector2Array, current_index: int) -> void:
	if points.size() < 2:
		return

	var smooth: PackedVector2Array = _catmull(points, 18)
	var split: int = clampi(current_index * 18, 0, smooth.size() - 1)
	var travelled: PackedVector2Array = smooth.slice(0, split + 1)
	var future: PackedVector2Array = smooth.slice(split)

	_add_route_part(parent, travelled, 1.0)
	_add_route_part(parent, future, 0.38)

func _add_route_part(parent: Node2D, points: PackedVector2Array, alpha: float) -> void:
	if points.size() < 2:
		return

	var shadow: Line2D = _line(points, ROUTE_SHADOW_TEX, ROUTE_W + 3.0)
	shadow.position = Vector2(2.0, 3.0)
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
		var target: int = int(_focus_pin.position.y + 47.0 - scroll.size.y * 0.52)
		scroll.scroll_vertical = maxi(target, 0)
	_update_hud()

func _update_hud() -> void:
	var campaign: Dictionary = _snapshot.get("campaign", {}) as Dictionary
	var completed: Array = campaign.get("completed_missions", []) as Array
	var total: int = EncounterCatalogScript.all().size()

	chapter_label.text = "CHAPTER 1"
	count_label.text = "%d/%d" % [mini(completed.size(), total), total]

	var fraction: float = clampf(float(completed.size()) / float(maxi(total, 1)), 0.0, 1.0)
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

func _outskirts_points() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(532.0, 104.0),
		Vector2(505.0, 248.0),
		Vector2(565.0, 400.0),
		Vector2(457.0, 544.0),
		Vector2(254.0, 686.0),
		Vector2(292.0, 836.0),
	])

func _suburbs_points() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(207.0, 108.0),
		Vector2(311.0, 282.0),
		Vector2(463.0, 456.0),
		Vector2(520.0, 636.0),
	])

func _outskirts_decor() -> Array:
	return [
		{"id": "note", "pos": Vector2(102, 500), "rot": -8.0, "scale": 0.45, "over": false},
		{"id": "arrow", "pos": Vector2(183, 720), "rot": -18.0, "scale": 0.32, "over": false},
		{"id": "yellow_pin", "pos": Vector2(610, 205), "rot": 0.0, "scale": 0.42, "over": true},
		{"id": "scrap", "pos": Vector2(570, 660), "rot": 8.0, "scale": 0.34, "over": false},
		{"id": "stain", "pos": Vector2(122, 822), "rot": 0.0, "scale": 0.48, "over": false},
	]

func _suburbs_decor() -> Array:
	return [
		{"id": "note", "pos": Vector2(592, 520), "rot": 7.0, "scale": 0.43, "over": false},
		{"id": "blue_pin", "pos": Vector2(625, 410), "rot": 0.0, "scale": 0.42, "over": true},
		{"id": "x", "pos": Vector2(116, 540), "rot": 8.0, "scale": 0.36, "over": false},
		{"id": "coffee", "pos": Vector2(145, 690), "rot": 0.0, "scale": 0.42, "over": false},
		{"id": "loose_string", "pos": Vector2(282, 710), "rot": -5.0, "scale": 0.34, "over": false},
	]

func _play_ui(cue: StringName) -> void:
	var audio := get_tree().get_first_node_in_group("fort_knocks_audio")
	if audio != null and audio.has_method("play_cue"):
		audio.call("play_cue", cue)
