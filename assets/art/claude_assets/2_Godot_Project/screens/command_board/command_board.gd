extends Control
## Command Board: vertically scrolling campaign board.
## Chapters -> regions (hand-composed sections) -> missions. Progress reads top to bottom.
## Opens centred on the current mission. Tapping a mission opens the shared MissionBriefing;
## the board never launches gameplay itself - listen to `deploy_requested`.

signal back_requested
signal mission_selected(mission: MissionData, context: Dictionary)
signal deploy_requested(mission_id: StringName, mission: MissionData, context: Dictionary)

const BOARD_W := 1080.0
const TOP_PAD := 40.0
const BOTTOM_PAD := 140.0
const BANNER_BLOCK := 170.0
const ROUTE_W := 20.0

const PinScene := preload("res://screens/command_board/mission_pin.tscn")
const PolaroidScene := preload("res://screens/command_board/region_polaroid.tscn")
const BG_TILES: Array[Texture2D] = [
	preload("res://assets/command_board/art/bg_board_tile_a.png"),
	preload("res://assets/command_board/art/bg_board_tile_b.png"),
	preload("res://assets/command_board/art/bg_board_tile_c.png"),
]
const ROUTE_TEX := preload("res://assets/command_board/ui/string_red_tile.png")
const ROUTE_SHADOW_TEX := preload("res://assets/command_board/ui/string_shadow_tile.png")
const BANNER_TEX := preload("res://assets/command_board/ui/chapter_banner_9s.png")
const TAPE_TEX := preload("res://assets/command_board/ui/tape_strip.png")
const DECOR := {
	"decor_coffee_ring": preload("res://assets/command_board/decor/decor_coffee_ring.png"),
	"decor_stain_dirt": preload("res://assets/command_board/decor/decor_stain_dirt.png"),
	"decor_note_lined": preload("res://assets/command_board/decor/decor_note_lined.png"),
	"decor_scrap_torn": preload("res://assets/command_board/decor/decor_scrap_torn.png"),
	"decor_marker_circle": preload("res://assets/command_board/decor/decor_marker_circle.png"),
	"decor_marker_x": preload("res://assets/command_board/decor/decor_marker_x.png"),
	"decor_marker_arrow": preload("res://assets/command_board/decor/decor_marker_arrow.png"),
	"decor_pushpin_blue": preload("res://assets/command_board/decor/decor_pushpin_blue.png"),
	"decor_pushpin_yellow": preload("res://assets/command_board/decor/decor_pushpin_yellow.png"),
	"decor_string_loose": preload("res://assets/command_board/decor/decor_string_loose.png"),
	"tape_strip": preload("res://assets/command_board/ui/tape_strip.png"),
}

@export var chapters: Array[ChapterData] = []
## The mission the player plays next. Everything before it is completed, everything after is locked.
@export var current_mission_id := &""
## Allow re-opening the briefing for completed missions.
@export var allow_replay := true

var _pins: Array[MissionPin] = []
var _chapter_ranges: Array[Dictionary] = []   # {y0, y1, chapter, done, total}
var _current_pin: MissionPin
var _board_h := 0.0


func _ready() -> void:
	%BackButton.pressed.connect(_on_back)
	%Briefing.deploy_requested.connect(func(id, m, ctx): deploy_requested.emit(id, m, ctx))
	%Scroll.get_v_scroll_bar().value_changed.connect(func(_v): _update_hud())
	%Scroll.resized.connect(_center_board)
	_apply_safe_area()
	build()


## Rebuild the board (call after changing chapters or current_mission_id).
func build() -> void:
	for c in %Board.get_children():
		c.queue_free()
	_pins.clear()
	_chapter_ranges.clear()
	_current_pin = null

	# flatten missions in campaign order to resolve states
	var order: Array[StringName] = []
	for ch in chapters:
		for rg in ch.regions:
			for m in rg.missions:
				order.append(m.id)
	var cur_idx := order.find(current_mission_id)
	if cur_idx < 0:
		cur_idx = 0

	var deco_under := Control.new(); deco_under.name = "DecorUnder"
	var polaroids := Control.new(); polaroids.name = "Polaroids"
	var deco_over := Control.new(); deco_over.name = "DecorOver"
	var route_layer := Node2D.new(); route_layer.name = "Route"
	var pins_layer := Control.new(); pins_layer.name = "Pins"
	var banners := Control.new(); banners.name = "Banners"
	var bg_layer := Control.new(); bg_layer.name = "Background"
	for n in [bg_layer, deco_under, polaroids, deco_over, banners, route_layer, pins_layer]:
		if n is Control:
			n.mouse_filter = Control.MOUSE_FILTER_IGNORE
		%Board.add_child(n)

	var y := TOP_PAD
	var idx := 0
	var points: PackedVector2Array = []
	var cur_point_index := 0
	for ch in chapters:
		var ch_y0 := y
		var ch_total := 0
		var ch_done := 0
		_add_banner(banners, ch, y)
		y += BANNER_BLOCK
		var number := 0
		for rg in ch.regions:
			var lay := rg.layout
			var mir := rg.mirrored
			var reached := idx <= cur_idx
			for d in lay.decor:
				_add_decor(deco_over if d.get("over", false) else deco_under, d, y, mir)
			var pol: RegionPolaroid = PolaroidScene.instantiate()
			polaroids.add_child(pol)
			pol.photo = rg.photo
			pol.caption = rg.display_name
			pol.attachment = lay.polaroid_attachment
			pol.dimmed = not reached
			var pp := _mx(lay.polaroid_position, mir)
			pol.position = Vector2(pp.x, y + pp.y) - pol.size * 0.5
			pol.pivot_offset = pol.size * 0.5
			pol.rotation_degrees = -lay.polaroid_rotation_deg if mir else lay.polaroid_rotation_deg
			for i in rg.missions.size():
				var m: MissionData = rg.missions[i]
				number += 1
				ch_total += 1
				var st := MissionPin.State.LOCKED
				if idx < cur_idx:
					st = MissionPin.State.COMPLETED
					ch_done += 1
				elif idx == cur_idx:
					st = MissionPin.State.CURRENT
				var lp := lay.pins[mini(i, lay.pins.size() - 1)]
				var c := _mx(lp, mir) + Vector2(0, y)
				var pin: MissionPin = PinScene.instantiate()
				pins_layer.add_child(pin)
				pin.position = c - MissionPin.CENTER
				var ctx := {"region_name": rg.display_name, "chapter_number": ch.number, "mission_number": number,
						"photo": rg.photo, "completed": st == MissionPin.State.COMPLETED, "region_id": rg.id}
				pin.setup(m, st, number, ctx)
				pin.pressed.connect(_on_pin_pressed.bind(pin))
				_pins.append(pin)
				if st == MissionPin.State.CURRENT:
					_current_pin = pin
					cur_point_index = points.size()
				points.append(c)
				idx += 1
			y += lay.section_height
		_chapter_ranges.append({"y0": ch_y0, "y1": y, "chapter": ch, "done": ch_done, "total": ch_total})
	_board_h = y + BOTTOM_PAD

	_build_route(route_layer, points, cur_point_index)
	_build_background(bg_layer)
	%Board.custom_minimum_size = Vector2(BOARD_W, _board_h)
	%Board.size = %Board.custom_minimum_size
	%BoardHolder.custom_minimum_size = Vector2(0, _board_h)
	_center_board()
	_focus_current.call_deferred()


## Scroll so the given mission sits in the middle of the visible board area.
func focus_mission(mission_id: StringName, animate := false) -> void:
	for p in _pins:
		if p.mission.id == mission_id:
			var target := int(p.position.y + MissionPin.CENTER.y - %Scroll.size.y * 0.5)
			if animate:
				create_tween().tween_property(%Scroll, "scroll_vertical", target, 0.35).set_trans(Tween.TRANS_CUBIC)
			else:
				%Scroll.scroll_vertical = target
			_update_hud()
			return


func _focus_current() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	if _current_pin:
		focus_mission(_current_pin.mission.id)
	_update_hud()


# --------------------------------------------------------------------------- building helpers
func _mx(p: Vector2, mirrored: bool) -> Vector2:
	return Vector2(BOARD_W - p.x, p.y) if mirrored else p


func _add_banner(parent: Control, ch: ChapterData, y: float) -> void:
	var b := NinePatchRect.new()
	b.texture = BANNER_TEX
	b.patch_margin_left = 30; b.patch_margin_right = 30; b.patch_margin_top = 30; b.patch_margin_bottom = 30
	b.size = Vector2(520, 96)
	b.position = Vector2((BOARD_W - b.size.x) * 0.5, y + 34)
	b.pivot_offset = b.size * 0.5
	b.rotation_degrees = -1.5 if ch.number % 2 == 0 else 1.2
	b.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(b)
	var l := Label.new()
	l.theme_type_variation = &"BannerLabel"
	l.text = "CHAPTER %d" % ch.number
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	l.offset_top = -4
	b.add_child(l)
	for side in [-1, 1]:
		var t := TextureRect.new()
		t.texture = TAPE_TEX
		t.mouse_filter = Control.MOUSE_FILTER_IGNORE
		t.scale = Vector2(0.45, 0.45)
		t.position = Vector2(-10 if side < 0 else b.size.x - 80, 6)
		t.rotation_degrees = -55 * side
		b.add_child(t)


func _add_decor(parent: Control, d: Dictionary, y: float, mirrored: bool) -> void:
	var tex: Texture2D = DECOR.get(d.get("id", ""))
	if tex == null:
		return
	var r := TextureRect.new()
	r.texture = tex
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var s: float = d.get("scale", 1.0)
	r.size = tex.get_size()
	r.pivot_offset = r.size * 0.5
	r.scale = Vector2(s, s)
	var p := _mx(d.get("pos", Vector2.ZERO), mirrored)
	r.position = Vector2(p.x, y + p.y) - r.size * 0.5
	var rot: float = d.get("rot", 0.0)
	r.rotation_degrees = -rot if mirrored else rot
	if mirrored and String(d.get("id", "")).begins_with("decor_marker_arrow"):
		r.flip_h = true
	parent.add_child(r)


func _build_route(parent: Node2D, pts: PackedVector2Array, cur_i: int) -> void:
	if pts.size() < 2:
		return
	var smooth := _catmull(pts, 16)
	var split := cur_i * 16
	var done := smooth.slice(0, split + 1)
	var future := smooth.slice(split)
	for part in [[done, 1.0], [future, 0.5]]:
		var p: PackedVector2Array = part[0]
		if p.size() < 2:
			continue
		var sh := _line(p + PackedVector2Array(), ROUTE_SHADOW_TEX, ROUTE_W + 4)
		sh.position = Vector2(3, 5)
		sh.modulate.a = part[1]
		parent.add_child(sh)
		var ln := _line(p, ROUTE_TEX, ROUTE_W)
		ln.modulate.a = part[1]
		parent.add_child(ln)


func _line(p: PackedVector2Array, tex: Texture2D, w: float) -> Line2D:
	var l := Line2D.new()
	l.points = p
	l.width = w
	l.texture = tex
	l.texture_mode = Line2D.LINE_TEXTURE_TILE
	l.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	l.joint_mode = Line2D.LINE_JOINT_ROUND
	l.antialiased = true
	return l


func _catmull(pts: PackedVector2Array, n: int) -> PackedVector2Array:
	var out: PackedVector2Array = []
	var p := PackedVector2Array([pts[0]]) + pts + PackedVector2Array([pts[pts.size() - 1]])
	for i in range(1, p.size() - 2):
		for k in n:
			var t := float(k) / n
			var t2 := t * t
			var t3 := t2 * t
			out.append(0.5 * ((2.0 * p[i]) + (-p[i - 1] + p[i + 1]) * t
					+ (2.0 * p[i - 1] - 5.0 * p[i] + 4.0 * p[i + 1] - p[i + 2]) * t2
					+ (-p[i - 1] + 3.0 * p[i] - 3.0 * p[i + 1] + p[i + 2]) * t3))
	out.append(pts[pts.size() - 1])
	return out


func _build_background(parent: Control) -> void:
	# chained tiles A->B->C->A... join seamlessly; repetition only every 3 tiles
	var th := 2160.0
	var n := int(ceil(_board_h / th))
	for i in n:
		var t := TextureRect.new()
		t.texture = BG_TILES[i % BG_TILES.size()]
		t.mouse_filter = Control.MOUSE_FILTER_IGNORE
		t.position = Vector2(0, i * th)
		t.size = Vector2(BOARD_W, th)
		parent.add_child(t)


func _center_board() -> void:
	%Board.position.x = maxf((%BoardHolder.size.x - BOARD_W) * 0.5, 0.0)


# --------------------------------------------------------------------------- HUD / input
func _update_hud() -> void:
	if _chapter_ranges.is_empty():
		return
	var center: float = %Scroll.scroll_vertical + %Scroll.size.y * 0.5
	var r: Dictionary = _chapter_ranges[0]
	for cr in _chapter_ranges:
		if center >= cr.y0:
			r = cr
	%ChapterLabel.text = "CHAPTER %d" % r.chapter.number
	%CountLabel.text = "%d/%d" % [r.done, r.total]
	var frac := float(r.done) / maxf(r.total, 1)
	var track: Control = %Track
	var inner := track.size.x - 12.0
	%Fill.visible = frac > 0.0
	%Fill.size = Vector2(maxf(inner * frac, 36.0), track.size.y - 12.0)


func _on_pin_pressed(pin: MissionPin) -> void:
	if pin.state == MissionPin.State.LOCKED:
		pin.shake()
		return
	if pin.state == MissionPin.State.COMPLETED and not allow_replay:
		return
	mission_selected.emit(pin.mission, pin.context)
	%Briefing.open(pin.mission, pin.context)


func _on_back() -> void:
	if %Briefing.is_open():
		%Briefing.close()
	else:
		back_requested.emit()


## Grow the top rail on notched phones so the back button stays clear of the notch.
func _apply_safe_area() -> void:
	var win := DisplayServer.window_get_size()
	if win.y <= 0:
		return
	var safe := DisplayServer.get_display_safe_area()
	var inset := float(safe.position.y) * (get_viewport_rect().size.y / float(win.y))
	if inset > 0.0 and inset < 200.0:
		%TopRail.offset_bottom += inset
		%TopContent.offset_top += inset
		%TopContent.offset_bottom += inset
		%Scroll.offset_top += inset
		%EdgeTop.offset_top += inset
		%EdgeTop.offset_bottom += inset
