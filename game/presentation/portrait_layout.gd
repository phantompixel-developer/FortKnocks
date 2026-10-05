class_name PortraitLayout
extends RefCounted

const DESIGN_SIZE := Vector2(720.0, 1280.0)
const BASE_SAFE_PADDING := 24.0
const META_BASE_POSITION := &"fort_knocks_baseline_position"

static func apply(
	root: Control,
	top_controls: Array,
	body_controls: Array,
	bottom_controls: Array
) -> void:
	if root == null or root.get_viewport() == null:
		return

	var viewport_size := root.get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return

	var insets := logical_safe_insets(root.get_viewport())
	var extra_size := Vector2(
		maxf(0.0, viewport_size.x - DESIGN_SIZE.x),
		maxf(0.0, viewport_size.y - DESIGN_SIZE.y)
	)

	# Keep the 720px composition centered inside expanded portrait viewports,
	# nudged away from asymmetric left/right cutouts when present.
	var horizontal_shift := extra_size.x * 0.5 + (insets.x - insets.z) * 0.5
	var top_shift := maxf(0.0, insets.y - BASE_SAFE_PADDING)
	var bottom_shift := extra_size.y - maxf(0.0, insets.w - BASE_SAFE_PADDING)
	var body_shift := extra_size.y * 0.5

	for item in top_controls:
		_apply_shift(item as Control, Vector2(horizontal_shift, top_shift))
	for item in body_controls:
		_apply_shift(item as Control, Vector2(horizontal_shift, body_shift))
	for item in bottom_controls:
		_apply_shift(item as Control, Vector2(horizontal_shift, bottom_shift))

static func logical_safe_insets(viewport: Viewport) -> Vector4:
	if viewport == null:
		return Vector4.ZERO

	var viewport_size := viewport.get_visible_rect().size
	var screen_size_i := DisplayServer.screen_get_size(DisplayServer.SCREEN_OF_MAIN_WINDOW)
	if screen_size_i.x <= 0 or screen_size_i.y <= 0:
		return Vector4.ZERO

	var safe := DisplayServer.get_display_safe_area(DisplayServer.SCREEN_OF_MAIN_WINDOW)
	if safe.size.x <= 0 or safe.size.y <= 0:
		return Vector4.ZERO

	var screen_size := Vector2(screen_size_i)
	var scale := Vector2(
		viewport_size.x / screen_size.x,
		viewport_size.y / screen_size.y
	)
	var left := float(safe.position.x) * scale.x
	var top := float(safe.position.y) * scale.y
	var right := float(screen_size_i.x - safe.end.x) * scale.x
	var bottom := float(screen_size_i.y - safe.end.y) * scale.y
	return Vector4(left, top, right, bottom)

static func _apply_shift(control: Control, shift: Vector2) -> void:
	if control == null:
		return
	if not control.has_meta(META_BASE_POSITION):
		control.set_meta(META_BASE_POSITION, control.position)
	var baseline := control.get_meta(META_BASE_POSITION) as Vector2
	control.position = baseline + shift
