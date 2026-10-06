class_name CommandBoardScreen
extends Control

signal mission_selected(mission: MissionDefinition)
signal back_requested

const EncounterCatalogScript := preload("res://game/campaign/encounter_catalog.gd")
const ThemeScript := preload("res://game/presentation/fort_knocks_theme.gd")
const ProductionUIScript := preload("res://game/presentation/production_ui.gd")

const BOARD_W := 720.0
const SCALE := 2.0 / 3.0
const TOP_PAD := 27.0
const BOTTOM_PAD := 93.0
const BANNER_BLOCK := 113.0
const ROUTE_W := 13.0
const OUTSKIRTS_H := 853.0
const SUBURBS_H := 667.0

const ART_ROOT := "res://assets/art/claude_assets/1_Asset_Kit/04_command_board"
const BG_TILES: Array[Texture2D] = [
	preload(ART_ROOT + "/art/bg_board_tile_a.png"),
	preload(ART_ROOT + "/art/bg_board_tile_b.png"),
	preload(ART_ROOT + "/art/bg_board_tile_c.png"),
]
const OUTSKIRTS_PHOTO := preload(ART_ROOT + "/art/region_photo_outskirts.png")
const SUBURBS_PHOTO := preload(ART_ROOT + "/art/region_photo_suburbs.png")
const ROUTE_TEX := preload(ART_ROOT + "/png/ui/string_red_tile.png")
const ROUTE_SHADOW_TEX := preload(ART_ROOT + "/png/ui/string_shadow_tile.png")
const BANNER_TEX := preload(ART_ROOT + "/png/ui/chapter_banner_9s.png")
const TAPE_TEX := preload(ART_ROOT + "/png/ui/tape_strip.png")
const POLAROID_FRAME := preload(ART_ROOT + "/png/ui/polaroid_frame.png")
const POLAROID_OVERLAY := preload(ART_ROOT + "/png/ui/polaroid_photo_overlay.png")
const PUSH_PIN := preload(ART_ROOT + "/png/ui/pushpin_red.png")
const PIN_COMPLETED := preload(ART_ROOT + "/png/ui/mission_pin_completed.png")
const PIN_CURRENT := preload(ART_ROOT + "/png/ui/mission_pin_current.png")
const PIN_AVAILABLE := preload(ART_ROOT + "/png/ui/mission_pin_available.png")
const PIN_LOCKED := preload(ART_ROOT + "/png/ui/mission_pin_locked.png")
const PIN_GLOW := preload(ART_ROOT + "/png/ui/mission_pin_current_glow.png")
const TAG_PAPER := preload(ART_ROOT + "/png/ui/tag_paper_9s.png")

const DECOR_TEXTURES := {
	"decor_coffee_ring": preload(ART_ROOT + "/png/decor/decor_coffee_ring.png"),
	"decor_stain_dirt": preload(ART_ROOT + "/png/decor/decor_stain_dirt.png"),
	"decor_note_lined": preload(ART_ROOT + "/png/decor/decor_note_lined.png"),
	"decor_scrap_torn": preload(ART_ROOT + "/png/decor/decor_scrap_torn.png"),
	"decor_marker_circle": preload(ART_ROOT + "/png/decor/decor_marker_circle.png"),
	"decor_marker_x": preload(ART_ROOT + "/png/decor/decor_marker_x.png"),
	"decor_marker_arrow": preload(ART_ROOT + "/png/decor/decor_marker_arrow.png"),
	"decor_pushpin_blue": preload(ART_ROOT + "/png/decor/decor_pushpin_blue.png"),
	"decor_pushpin_yellow": preload(ART_ROOT + "/png/decor/decor_pushpin_yellow.png"),
	"decor_string_loose": preload(ART_ROOT + "/png/decor/decor_string_loose.png"),
	"tape_strip": preload(ART_ROOT + "/png/ui/tape_strip.png"),
}

@onready var scroll: ScrollContainer = %Scroll
@onready var board_holder: Control = %BoardHolder
@onready var board: Control = %Board
@onready var back_button: TextureButton = %BackButton
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
var _current_route_index := 0
var _board_h := 0.0
var _briefing_mission: MissionDefinition

func _ready() -> void:
	ThemeScript.apply(self)
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
	_current_route_index = 0

	var missions: Array[MissionDefinition] = EncounterCatalogScript.all()
	var outskirts: Array[MissionDefinition] = []
	var suburbs: Array[MissionDefinition] = []
	for mission in missions:
		if mission.id.begins_with("suburbs_"):
			suburbs.append(mission)
		else:
			outskirts.append(mission)

	var campaign := _snapshot.get("campaign", {}) as Dictionary
	var unlocked := campaign.get("unlocked_missions", []) as Array
	var completed := campaign.get("completed_missions", []) as Array

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
	var y := TOP_PAD

	_add_chapter_banner(banners, "CHAPTER 1", y, false)
	y += BANNER_BLOCK

	var outskirts_reached := _region_reached(outskirts, unlocked, completed)
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
		y,
		OUTSKIRTS_H,
		false,
		-4.0,
		0,
		outskirts_reached,
		unlocked,
		completed,
		route_points
	)
	y += OUTSKIRTS_H

	var suburbs_reached := _region_reached(suburbs, unlocked, completed)
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
		y,
		SUBURBS_H,
		true,
		-4.0,
		0,
		suburbs_reached,
		unlocked,
		completed,
		route_points
	)
	y += SUBURBS_H

	_add_chapter_banner(banners, "CHAPTER 2 • LOCKED", y + 22.0, true)
	_board_h = y + BANNER_BLOCK + BOTTOM_PAD

	_build_route(route_layer, route_points, _current_route_index)
	_build_background(background)
	board.custom_minimum_size = Vector2(BOARD_W, _board_h)
	board.size = board.custom_minimum_size
	board_holder.custom_minimum_size = Vector2(0.0, _board_h)

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
	y: float,
	section_height: float,
	mirrored: bool,
	polaroid_rotation: float,
	polaroid_attachment: int,
	reached: bool,
	unlocked: Array,
	completed: Array,
	route_points: PackedVector2Array
) -> void:
	for item in decor:
		var target := decor_over if bool(item.get("over", false)) else decor_under
		_add_decor(target, item, y, mirrored)

	var polaroid_center := _mirror_point(Vector2(300.0, 250.0) * SCALE, mirrored)
	if region_name == "SUBURBS":
		polaroid_center = _mirror_point(Vector2(290.0, 250.0) * SCALE, mirrored)
	_add_polaroid(
		polaroid_layer,
		photo,
		region_name,
		polaroid_center + Vector2(0.0, y),
		-polaroid_rotation if mirrored else polaroid_rotation,
		polaroid_attachment,
		not reached
	)

	var current_claimed := _current_pin != null
	for i in range(mini(missions.size(), local_points.size())):
		var mission := missions[i]
		var local_point := _mirror_point(local_points[i], mirrored)
		var center := local_point + Vector2(0.0, y)
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

		var pin := _create_mission_pin(mission, state, mission.campaign_order)
		pin.position = center - Vector2(47.0, 45.0)
		pins_layer.add_child(pin)
		_pin_buttons.append(pin)
		_pin_missions.append(mission)

		if state == "current":
			_current_pin = pin
			_current_route_index = route_points.size() - 1

	if _current_pin == null and not missions.is_empty() and route_points.size() > 0:
		_current_route_index = route_points.size() - 1

func _create_mission_pin(mission: MissionDefinition, state: String, number: int) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(93.0, 93.0)
	button.size = Vector2(93.0, 93.0)
	button.focus_mode = Control.FOCUS_NONE
	button.flat = true
	button.mouse_filter = Control.MOUSE_FILTER_STOP

	var glow := TextureRect.new()
	glow.name = "_Glow"
	glow.visible = state == "current"
	glow.position = Vector2(-13.0, -15.0)
	glow.size = Vector2(120.0, 120.0)
	glow.texture = PIN_GLOW
	glow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(glow)

	var icon := TextureRect.new()
	icon.position = Vector2(11.0, 11.0)
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
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(icon)

	var tag := NinePatchRect.new()
	tag.position = Vector2(27.0, 69.0)
	tag.size = Vector2(40.0, 24.0)
	tag.texture = TAG_PAPER
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
	label.add_theme_color_override("font_color", Color(0.227, 0.173, 0.11, 1))
	label.add_theme_font_size_override("font_size", 16)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tag.add_child(label)

	if state == "locked":
		button.pressed.connect(_shake_pin.bind(button))
	else:
		button.pressed.connect(_open_briefing.bind(mission))

	if state == "current":
		glow.pivot_offset = glow.size * 0.5
		var pulse := create_tween().set_loops()
		pulse.tween_property(glow, "scale", Vector2(1.15, 1.15), 0.7).set_trans(Tween.TRANS_SINE)
		pulse.parallel().tween_property(glow, "modulate:a", 0.55, 0.7).set_trans(Tween.TRANS_SINE)
		pulse.tween_property(glow, "scale", Vector2(0.9, 0.9), 0.7).set_trans(Tween.TRANS_SINE)
		pulse.parallel().tween_property(glow, "modulate:a", 1.0, 0.7).set_trans(Tween.TRANS_SINE)

	return button

func _shake_pin(pin: Button) -> void:
	_play_ui(&"ui_back")
	var start_x := pin.position.x
	var tween := create_tween()
	for delta in [7.0, -6.0, 4.0, -3.0, 0.0]:
		tween.tween_property(pin, "position:x", start_x + delta, 0.05)

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
	root.size = Vector2(307.0, 280.0)
	root.position = center - root.size * 0.5
	root.pivot_offset = root.size * 0.5
	root.rotation_degrees = rotation_degrees_value
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var frame := TextureRect.new()
	frame.size = root.size
	frame.texture = POLAROID_FRAME
	frame.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(frame)

	var photo_rect := TextureRect.new()
	photo_rect.position = Vector2(27.0, 23.0)
	photo_rect.size = Vector2(253.0, 167.0)
	photo_rect.texture = photo
	photo_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	photo_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	photo_rect.self_modulate = Color(0.55, 0.55, 0.60, 1.0) if dimmed else Color.WHITE
	photo_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(photo_rect)

	var overlay := TextureRect.new()
	overlay.position = Vector2(27.0, 23.0)
	overlay.size = Vector2(253.0, 167.0)
	overlay.texture = POLAROID_OVERLAY
	overlay.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(overlay)

	var label := Label.new()
	label.position = Vector2(20.0, 195.0)
	label.size = Vector2(267.0, 63.0)
	label.text = caption
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", Color(0.106, 0.086, 0.063, 1))
	label.add_theme_font_size_override("font_size", 27)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(label)

	var attach := TextureRect.new()
	if attachment == 0:
		attach.texture = PUSH_PIN
		attach.position = Vector2(129.0, -17.0)
		attach.size = Vector2(48.0, 53.0)
	else:
		attach.texture = TAPE_TEX
		attach.position = Vector2(93.0, -15.0)
		attach.size = Vector2(133.0, 47.0)
		attach.rotation = -0.05
	attach.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	attach.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	attach.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(attach)

	parent.add_child(root)

func _add_chapter_banner(parent: Control, text_value: String, y: float, locked: bool) -> void:
	var banner := NinePatchRect.new()
	banner.texture = BANNER_TEX
	banner.patch_margin_left = 20
	banner.patch_margin_top = 20
	banner.patch_margin_right = 20
	banner.patch_margin_bottom = 20
	banner.size = Vector2(347.0, 64.0)
	banner.position = Vector2((BOARD_W - banner.size.x) * 0.5, y + 23.0)
	banner.pivot_offset = banner.size * 0.5
	banner.rotation_degrees = -1.2 if locked else 1.2
	banner.modulate = Color(0.66, 0.66, 0.66, 1.0) if locked else Color.WHITE
	banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(banner)

	var label := Label.new()
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.offset_top = -3.0
	label.text = text_value
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", Color(0.165, 0.114, 0.071, 1))
	label.add_theme_font_size_override("font_size", 24)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	banner.add_child(label)

	for side in [-1, 1]:
		var tape := TextureRect.new()
		tape.texture = TAPE_TEX
		tape.size = Vector2(70.0, 24.0)
		tape.position = Vector2(-7.0 if side < 0 else banner.size.x - 53.0, 4.0)
		tape.rotation_degrees = -55.0 * float(side)
		tape.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tape.mouse_filter = Control.MOUSE_FILTER_IGNORE
		banner.add_child(tape)

func _add_decor(parent: Control, data: Dictionary, y: float, mirrored: bool) -> void:
	var id := str(data.get("id", ""))
	var texture := DECOR_TEXTURES.get(id) as Texture2D
	if texture == null:
		return

	var rect := TextureRect.new()
	rect.texture = texture
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.size = texture.get_size() * SCALE
	rect.pivot_offset = rect.size * 0.5
	var scale_value := float(data.get("scale", 1.0))
	rect.scale = Vector2(scale_value, scale_value)

	var raw_position: Vector2 = data.get("pos", Vector2.ZERO)
	var position_scaled := raw_position * SCALE
	position_scaled = _mirror_point(position_scaled, mirrored)
	rect.position = Vector2(position_scaled.x, y + position_scaled.y) - rect.size * 0.5

	var rotation_value := float(data.get("rot", 0.0))
	rect.rotation_degrees = -rotation_value if mirrored else rotation_value
	if mirrored and id == "decor_marker_arrow":
		rect.flip_h = true
	parent.add_child(rect)

func _build_route(parent: Node2D, points: PackedVector2Array, current_index: int) -> void:
	if points.size() < 2:
		return

	var smooth := _catmull(points, 16)
	var split := clampi(current_index * 16, 0, smooth.size() - 1)
	var completed_line := smooth.slice(0, split + 1)
	var future_line := smooth.slice(split)

	_add_route_part(parent, completed_line, 1.0)
	_add_route_part(parent, future_line, 0.50)

func _add_route_part(parent: Node2D, points: PackedVector2Array, alpha: float) -> void:
	if points.size() < 2:
		return

	var shadow := _line(points, ROUTE_SHADOW_TEX, ROUTE_W + 3.0)
	shadow.position = Vector2(2.0, 3.0)
	shadow.modulate.a = alpha
	parent.add_child(shadow)

	var line := _line(points, ROUTE_TEX, ROUTE_W)
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
			var t := float(sample) / float(samples)
			var t2 := t * t
			var t3 := t2 * t
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
	var tile_height := 1440.0
	var tile_count := int(ceil(_board_h / tile_height))
	for i in range(tile_count):
		var tile := TextureRect.new()
		tile.texture = BG_TILES[i % BG_TILES.size()]
		tile.position = Vector2(0.0, float(i) * tile_height)
		tile.size = Vector2(BOARD_W, tile_height)
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
	var tween := create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
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
	var mission := _briefing_mission
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
	if _current_pin != null:
		var target := int(_current_pin.position.y + 47.0 - scroll.size.y * 0.50)
		scroll.scroll_vertical = maxi(target, 0)
	_update_hud()

func _update_hud() -> void:
	var campaign := _snapshot.get("campaign", {}) as Dictionary
	var completed := campaign.get("completed_missions", []) as Array
	var total := EncounterCatalogScript.all().size()
	chapter_label.text = "CHAPTER 1"
	count_label.text = "%d/%d" % [mini(completed.size(), total), total]

	var fraction := clampf(float(completed.size()) / float(maxi(total, 1)), 0.0, 1.0)
	var inner_width := maxf(progress_track.size.x - 8.0, 0.0)
	progress_fill.visible = fraction > 0.0
	progress_fill.size = Vector2(
		maxf(inner_width * fraction, 24.0) if fraction > 0.0 else 0.0,
		maxf(progress_track.size.y - 8.0, 0.0)
	)

func _center_board() -> void:
	board.position.x = maxf((board_holder.size.x - BOARD_W) * 0.5, 0.0)

func _apply_safe_area() -> void:
	var window_size := DisplayServer.window_get_size()
	if window_size.y <= 0:
		return

	var safe := DisplayServer.get_display_safe_area()
	if safe.size.y <= 0:
		return

	var viewport_size := get_viewport_rect().size
	var top_inset := float(safe.position.y) * (viewport_size.y / float(window_size.y))
	var bottom_inset := float(window_size.y - (safe.position.y + safe.size.y)) * (viewport_size.y / float(window_size.y))

	if top_inset > 0.0 and top_inset < 200.0:
		%TopRail.offset_bottom += top_inset
		%TopContent.offset_top += top_inset
		%TopContent.offset_bottom += top_inset
		scroll.offset_top += top_inset
		%EdgeTop.offset_top += top_inset
		%EdgeTop.offset_bottom += top_inset

	if bottom_inset > 0.0 and bottom_inset < 200.0:
		$Hud.offset_top -= bottom_inset
		$Hud.offset_bottom -= bottom_inset
		scroll.offset_bottom -= bottom_inset
		$EdgeBottom.offset_top -= bottom_inset
		$EdgeBottom.offset_bottom -= bottom_inset

func _mirror_point(point: Vector2, mirrored: bool) -> Vector2:
	return Vector2(BOARD_W - point.x, point.y) if mirrored else point

func _outskirts_points() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(770.0, 140.0) * SCALE,
		Vector2(880.0, 385.0) * SCALE,
		Vector2(690.0, 590.0) * SCALE,
		Vector2(430.0, 740.0) * SCALE,
		Vector2(250.0, 945.0) * SCALE,
		Vector2(520.0, 1150.0) * SCALE,
	])

func _suburbs_points() -> PackedVector2Array:
	return PackedVector2Array([
		Vector2(770.0, 150.0) * SCALE,
		Vector2(868.0, 400.0) * SCALE,
		Vector2(660.0, 640.0) * SCALE,
		Vector2(380.0, 820.0) * SCALE,
	])

func _outskirts_decor() -> Array:
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

func _suburbs_decor() -> Array:
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

func _play_ui(cue: StringName) -> void:
	var audio := get_tree().get_first_node_in_group("fort_knocks_audio")
	if audio != null and audio.has_method("play_cue"):
		audio.call("play_cue", cue)
