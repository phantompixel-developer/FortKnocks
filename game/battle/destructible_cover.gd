class_name DestructibleCover
extends StaticBody2D

const ProductionArtScript := preload("res://game/presentation/production_art.gd")
const COMPACT_TEXTURE_PATH := "res://assets/art/production/vehicles/run_down_compact.svg"
const SEDAN_TEXTURE_PATH := "res://assets/art/production/vehicles/old_sedan.svg"
const PICKUP_TEXTURE_PATH := "res://assets/art/production/vehicles/pickup.svg"
const TECHNICAL_TEXTURE_PATH := "res://assets/art/production/vehicles/improvised_technical.svg"

var _vehicle_textures: Dictionary = {}

signal health_changed(current: int, maximum: int)
signal destroyed

@export var max_health := 150
@export var body_color := Color("7a6554")
@export var facing := 1

var health := 150
var is_destroyed := false
var _reaction_tween: Tween
var _body_size := Vector2(240.0, 95.0)
var _visual_profile := 0
var _module_id := ""

func _ready() -> void:
	health = max_health
	_sync_body_size_from_collision()
	queue_redraw()

func configure_platform(
	definition: CombatPlatformDefinition,
	module_definition: PlatformModuleDefinition = null
) -> void:
	if definition == null:
		return

	var health_bonus := module_definition.cover_health_bonus if module_definition != null else 0
	max_health = maxi(1, definition.cover_health + health_bonus)
	health = max_health
	is_destroyed = false
	body_color = definition.cover_color
	_body_size = definition.cover_size
	_visual_profile = definition.visual_profile
	_module_id = module_definition.id if module_definition != null else ""
	collision_layer = 1
	collision_mask = 1

	var collision_shape := $CollisionShape2D as CollisionShape2D
	if collision_shape != null:
		var rectangle := collision_shape.shape as RectangleShape2D
		if rectangle != null:
			var unique_rectangle := rectangle.duplicate() as RectangleShape2D
			unique_rectangle.size = _body_size
			collision_shape.shape = unique_rectangle
		collision_shape.set_deferred("disabled", false)

	health_changed.emit(health, max_health)
	queue_redraw()

func apply_hit(damage: int, impulse: Vector2, _hit_position: Vector2) -> void:
	if is_destroyed:
		return

	health = maxi(0, health - damage)
	_play_hit_reaction(impulse)
	health_changed.emit(health, max_health)

	if health <= 0:
		is_destroyed = true
		collision_layer = 0
		collision_mask = 0
		$CollisionShape2D.set_deferred("disabled", true)
		destroyed.emit()

	queue_redraw()

func get_damage_stage() -> int:
	if is_destroyed or health <= 0:
		return 3

	var ratio := float(health) / float(max_health)
	if ratio <= 0.34:
		return 2
	if ratio <= 0.67:
		return 1
	return 0

func _sync_body_size_from_collision() -> void:
	var collision_shape := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision_shape == null:
		return
	var rectangle := collision_shape.shape as RectangleShape2D
	if rectangle != null:
		_body_size = rectangle.size

func _play_hit_reaction(impulse: Vector2) -> void:
	if _reaction_tween != null and _reaction_tween.is_running():
		_reaction_tween.kill()

	var direction := signf(impulse.x)
	if is_zero_approx(direction):
		direction = 1.0

	modulate = Color(1.45, 1.16, 0.78, 1.0)
	rotation = deg_to_rad(1.8 * direction)
	_reaction_tween = create_tween()
	_reaction_tween.set_parallel(true)
	_reaction_tween.tween_property(self, "modulate", Color.WHITE, 0.18)
	_reaction_tween.tween_property(self, "rotation", 0.0, 0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _draw() -> void:
	var stage := get_damage_stage()
	if stage >= 3:
		_draw_rubble()
		return

	# Fort Knocks player platforms use the authored production vehicle family.
	# Enemy cover deliberately keeps faction-neutral procedural presentation.
	if facing > 0 and _draw_production_platform(stage):
		return

	var darkening := float(stage) * 0.11
	var shell := body_color.darkened(darkening)
	var outline := Color("181c1a")
	var width := _body_size.x
	var half_width := width * 0.5
	var body_height := maxf(68.0, _body_size.y - 17.0)
	var body_top := -body_height * 0.5
	var lower_y := body_top + body_height

	# Layered civilian shell: dark chassis, dented body, mismatched salvage panels.
	draw_rect(Rect2(-half_width, body_top + 4.0, width, body_height - 4.0), outline)
	draw_rect(Rect2(-half_width + 6.0, body_top + 8.0, width - 12.0, body_height - 15.0), shell)
	draw_rect(Rect2(-half_width + 12.0, body_top + body_height * 0.52, width - 24.0, 22.0), shell.darkened(0.16))
	draw_line(Vector2(-half_width + 18.0, lower_y - 11.0), Vector2(half_width - 18.0, lower_y - 11.0), Color("68716a"), 5.0)

	if _visual_profile == 1:
		_draw_sedan_cabin(shell, outline, half_width, body_top)
	elif _visual_profile == 2:
		_draw_pickup_cabin(shell, outline, half_width, body_top)
	elif _visual_profile == 3:
		_draw_technical_cabin(shell, outline, half_width, body_top)
	else:
		_draw_compact_cabin(shell, outline, body_top)

	# Wheels and hubs remain exaggerated for quick silhouette recognition.
	var wheel_y := lower_y
	var wheel_offset := half_width - 48.0
	for x in [-wheel_offset, wheel_offset]:
		draw_circle(Vector2(x, wheel_y), 29, outline)
		draw_circle(Vector2(x, wheel_y), 17, Color("4e5551"))
		draw_circle(Vector2(x, wheel_y), 7, Color("8b8065"))

	# Fort Knocks salvage language: welded plate + hazard slash, readable even on the compact.
	draw_rect(Rect2(-22, body_top + 22.0, 72, 22), Color("4a514c"))
	draw_line(Vector2(-10, body_top + 42.0), Vector2(6, body_top + 24.0), Color("d4aa55"), 6.0)
	draw_line(Vector2(11, body_top + 42.0), Vector2(27, body_top + 24.0), Color("a45f42"), 6.0)
	draw_circle(Vector2(-14, body_top + 27.0), 3.0, Color("171b1a"))
	draw_circle(Vector2(42, body_top + 39.0), 3.0, Color("171b1a"))

	# Authored damage stages open the silhouette without adding arbitrary physics debris.
	if stage >= 1:
		draw_line(Vector2(-half_width + 68.0, body_top + 12.0), Vector2(-18.0, 5.0), Color("272d2a"), 6.0)
		draw_line(Vector2(28.0, body_top - 24.0), Vector2(10.0, body_top - 1.0), Color("b7c0b6"), 3.0)
		draw_rect(Rect2(-half_width + 18.0, body_top + 40.0, 45.0, 10.0), Color("6b4939"))
	if stage >= 2:
		draw_line(Vector2(half_width - 88.0, body_top + 8.0), Vector2(half_width - 36.0, wheel_y - 14.0), Color("252b28"), 8.0)
		draw_line(Vector2(-half_width + 24.0, body_top + 18.0), Vector2(-half_width + 72.0, wheel_y - 12.0), Color("252b28"), 7.0)
		draw_polygon(
			PackedVector2Array([
				Vector2(half_width - 72.0, body_top + 12.0),
				Vector2(half_width - 17.0, body_top + 16.0),
				Vector2(half_width - 28.0, body_top + 48.0),
				Vector2(half_width - 82.0, body_top + 42.0),
			]),
			PackedColorArray([Color("2d322f")])
		)


func _draw_production_platform(stage: int) -> bool:
	var platform_id := _platform_id_from_visual_profile()
	var texture := _texture_for_platform(platform_id)
	if texture == null:
		return false

	var target_width := _body_size.x + 46.0
	var aspect := 0.50 if platform_id == "run_down_compact" else 0.47
	var target_height := target_width * aspect
	var tint := Color.WHITE.darkened(float(stage) * 0.08)
	var target := Rect2(
		-target_width * 0.5,
		-target_height * 0.72,
		target_width,
		target_height
	)
	draw_texture_rect(texture, target, false, tint)
	_draw_production_module_overlay(target)

	var half_width := target_width * 0.5
	if stage >= 1:
		draw_line(Vector2(-half_width * 0.58, -42), Vector2(-half_width * 0.30, -10), Color("1b2224"), 7.0)
		draw_line(Vector2(half_width * 0.22, -62), Vector2(half_width * 0.08, -34), Color("d7c6a4", 0.72), 3.0)
		draw_line(Vector2(-half_width * 0.66, -12), Vector2(-half_width * 0.42, -4), Color("b65c36", 0.76), 5.0)
	if stage >= 2:
		draw_polygon(
			PackedVector2Array([
				Vector2(half_width * 0.28, -48),
				Vector2(half_width * 0.66, -43),
				Vector2(half_width * 0.61, -10),
				Vector2(half_width * 0.25, -16),
			]),
			PackedColorArray([Color("111820", 0.92)])
		)
		draw_line(Vector2(half_width * 0.43, -58), Vector2(half_width * 0.63, -18), Color("090d11"), 8.0)
		draw_line(Vector2(-half_width * 0.72, -38), Vector2(-half_width * 0.52, 4), Color("090d11"), 7.0)
	return true

func _platform_id_from_visual_profile() -> String:
	match _visual_profile:
		1:
			return "old_sedan"
		2:
			return "pickup"
		3:
			return "improvised_technical"
		_:
			return "run_down_compact"

func _texture_for_platform(platform_id: String) -> Texture2D:
	if _vehicle_textures.has(platform_id):
		return _vehicle_textures[platform_id] as Texture2D

	var path := COMPACT_TEXTURE_PATH
	match platform_id:
		"old_sedan":
			path = SEDAN_TEXTURE_PATH
		"pickup":
			path = PICKUP_TEXTURE_PATH
		"improvised_technical":
			path = TECHNICAL_TEXTURE_PATH

	var texture: Texture2D = ProductionArtScript.texture_from_svg(path)
	_vehicle_textures[platform_id] = texture
	return texture

func _draw_production_module_overlay(target: Rect2) -> void:
	if _module_id.is_empty():
		return
	var anchor := target.position + Vector2(target.size.x * 0.78, target.size.y * 0.42)
	match _module_id:
		"spotter_rack":
			draw_line(anchor, anchor + Vector2(0, -42), Color("172123"), 8.0)
			draw_circle(anchor + Vector2(0, -49), 11.0, Color("5d918e"))
			draw_circle(anchor + Vector2(0, -49), 4.0, Color("d3f1eb"))
		"ballast_crates":
			draw_rect(Rect2(anchor.x - 34, anchor.y - 21, 33, 25), Color("6d5d43"))
			draw_rect(Rect2(anchor.x + 5, anchor.y - 16, 29, 20), Color("806c4b"))
		"twin_field_rack":
			draw_rect(Rect2(anchor.x - 27, anchor.y - 48, 21, 47), Color("52605c"))
			draw_rect(Rect2(anchor.x + 6, anchor.y - 48, 21, 47), Color("405b56"))
			draw_circle(anchor + Vector2(-17, -38), 4.0, Color("e7ad3c"))
			draw_circle(anchor + Vector2(16, -38), 4.0, Color("77b6bf"))
		"stabilizer_rig":
			draw_line(anchor + Vector2(-16, 0), anchor + Vector2(-34, 34), Color("65716d"), 7.0)
			draw_line(anchor + Vector2(16, 0), anchor + Vector2(34, 34), Color("65716d"), 7.0)
			draw_line(anchor + Vector2(-42, 34), anchor + Vector2(-26, 34), Color("8a7b5e"), 7.0)
			draw_line(anchor + Vector2(26, 34), anchor + Vector2(42, 34), Color("8a7b5e"), 7.0)


func _draw_compact_cabin(shell: Color, outline: Color, body_top: float) -> void:
	draw_polygon(
		PackedVector2Array([
			Vector2(-67, body_top + 1),
			Vector2(-33, body_top - 45),
			Vector2(48, body_top - 45),
			Vector2(85, body_top + 1),
		]),
		PackedColorArray([outline])
	)
	draw_polygon(
		PackedVector2Array([
			Vector2(-58, body_top - 2),
			Vector2(-27, body_top - 37),
			Vector2(42, body_top - 37),
			Vector2(74, body_top - 2),
		]),
		PackedColorArray([shell.lightened(0.055)])
	)
	draw_polygon(
		PackedVector2Array([
			Vector2(-24, body_top - 33),
			Vector2(3, body_top - 33),
			Vector2(3, body_top - 7),
			Vector2(-48, body_top - 7),
		]),
		PackedColorArray([Color("435653")])
	)
	draw_polygon(
		PackedVector2Array([
			Vector2(8, body_top - 33),
			Vector2(38, body_top - 33),
			Vector2(64, body_top - 7),
			Vector2(8, body_top - 7),
		]),
		PackedColorArray([Color("516662")])
	)
	draw_line(Vector2(6, body_top - 37), Vector2(6, body_top - 2), outline, 5.0)

func _draw_sedan_cabin(shell: Color, outline: Color, half_width: float, body_top: float) -> void:
	draw_polygon(
		PackedVector2Array([
			Vector2(-half_width + 58.0, body_top + 1.0),
			Vector2(-half_width + 106.0, body_top - 52.0),
			Vector2(half_width - 82.0, body_top - 52.0),
			Vector2(half_width - 28.0, body_top + 1.0),
		]),
		PackedColorArray([outline])
	)
	draw_polygon(
		PackedVector2Array([
			Vector2(-half_width + 69.0, body_top - 3.0),
			Vector2(-half_width + 112.0, body_top - 43.0),
			Vector2(half_width - 89.0, body_top - 43.0),
			Vector2(half_width - 40.0, body_top - 3.0),
		]),
		PackedColorArray([shell.lightened(0.06)])
	)
	draw_rect(Rect2(-half_width + 119.0, body_top - 37.0, 72.0, 29.0), Color("435653"))
	draw_rect(Rect2(10.0, body_top - 37.0, half_width - 103.0, 29.0), Color("526864"))
	draw_line(Vector2(0, body_top - 43.0), Vector2(0, body_top - 3.0), outline, 5.0)
	draw_line(Vector2(-half_width + 98.0, body_top - 10.0), Vector2(-half_width + 126.0, body_top - 44.0), Color("a45f42"), 5.0)

func _draw_pickup_cabin(shell: Color, outline: Color, half_width: float, body_top: float) -> void:
	draw_polygon(
		PackedVector2Array([
			Vector2(-half_width + 43.0, body_top + 1.0),
			Vector2(-half_width + 82.0, body_top - 52.0),
			Vector2(-12.0, body_top - 52.0),
			Vector2(27.0, body_top + 1.0),
		]),
		PackedColorArray([outline])
	)
	draw_polygon(
		PackedVector2Array([
			Vector2(-half_width + 54.0, body_top - 3.0),
			Vector2(-half_width + 88.0, body_top - 43.0),
			Vector2(-18.0, body_top - 43.0),
			Vector2(16.0, body_top - 3.0),
		]),
		PackedColorArray([shell.lightened(0.06)])
	)
	draw_rect(Rect2(-half_width + 92.0, body_top - 37.0, half_width + 66.0, 29.0), Color("485d59"))
	draw_rect(Rect2(40.0, body_top + 4.0, half_width - 51.0, 23.0), shell.darkened(0.12))
	draw_line(Vector2(44.0, body_top + 6.0), Vector2(half_width - 14.0, body_top + 6.0), Color("758076"), 4.0)

	if _module_id == "spotter_rack":
		draw_line(Vector2(72.0, body_top + 2.0), Vector2(72.0, body_top - 64.0), outline, 8.0)
		draw_line(Vector2(72.0, body_top - 57.0), Vector2(112.0, body_top - 73.0), outline, 6.0)
		draw_circle(Vector2(119.0, body_top - 75.0), 13.0, Color("6c9589"))
		draw_circle(Vector2(119.0, body_top - 75.0), 6.0, Color("b6ddd4"))
	elif _module_id == "ballast_crates":
		for rect in [Rect2(49.0, body_top - 24.0, 58.0, 36.0), Rect2(112.0, body_top - 18.0, 49.0, 30.0)]:
			draw_rect(rect, Color("655943"))
			draw_rect(Rect2(rect.position + Vector2(4, 4), rect.size - Vector2(8, 8)), Color("796b4d"))
			draw_line(rect.position + Vector2(4, rect.size.y * 0.5), rect.position + Vector2(rect.size.x - 4, rect.size.y * 0.5), Color("4b4437"), 3.0)

func _draw_technical_cabin(shell: Color, outline: Color, half_width: float, body_top: float) -> void:
	# Reinforced pickup-derived silhouette: armored cab, support cage and dedicated rear mount.
	draw_polygon(
		PackedVector2Array([
			Vector2(-half_width + 36.0, body_top + 1.0),
			Vector2(-half_width + 78.0, body_top - 58.0),
			Vector2(-24.0, body_top - 58.0),
			Vector2(20.0, body_top + 1.0),
		]),
		PackedColorArray([outline])
	)
	draw_polygon(
		PackedVector2Array([
			Vector2(-half_width + 48.0, body_top - 4.0),
			Vector2(-half_width + 86.0, body_top - 47.0),
			Vector2(-30.0, body_top - 47.0),
			Vector2(9.0, body_top - 4.0),
		]),
		PackedColorArray([shell.lightened(0.05)])
	)
	draw_rect(Rect2(-half_width + 91.0, body_top - 41.0, half_width + 58.0, 31.0), Color("3f5550"))
	draw_rect(Rect2(37.0, body_top + 3.0, half_width - 48.0, 28.0), shell.darkened(0.16))
	draw_line(Vector2(35.0, body_top - 4.0), Vector2(35.0, body_top - 76.0), outline, 8.0)
	draw_line(Vector2(35.0, body_top - 74.0), Vector2(half_width - 30.0, body_top - 74.0), outline, 7.0)
	draw_line(Vector2(half_width - 30.0, body_top - 74.0), Vector2(half_width - 30.0, body_top + 2.0), outline, 8.0)
	draw_rect(Rect2(-half_width + 12.0, body_top + 18.0, 82.0, 18.0), Color("5a493d"))
	draw_line(Vector2(-half_width + 24.0, body_top + 34.0), Vector2(-half_width + 42.0, body_top + 19.0), Color("d4aa55"), 5.0)
	draw_line(Vector2(-half_width + 45.0, body_top + 34.0), Vector2(-half_width + 63.0, body_top + 19.0), Color("a45f42"), 5.0)

	if _module_id == "twin_field_rack":
		draw_rect(Rect2(58.0, body_top - 47.0, 38.0, 58.0), outline)
		draw_rect(Rect2(63.0, body_top - 42.0, 28.0, 48.0), Color("5d655f"))
		draw_rect(Rect2(105.0, body_top - 47.0, 38.0, 58.0), outline)
		draw_rect(Rect2(110.0, body_top - 42.0, 28.0, 48.0), Color("47655f"))
		draw_circle(Vector2(77.0, body_top - 31.0), 5.0, Color("d4aa55"))
		draw_circle(Vector2(124.0, body_top - 31.0), 5.0, Color("77b6bf"))
	elif _module_id == "stabilizer_rig":
		draw_line(Vector2(66.0, body_top + 7.0), Vector2(92.0, body_top + 45.0), outline, 8.0)
		draw_line(Vector2(half_width - 60.0, body_top + 7.0), Vector2(half_width - 88.0, body_top + 45.0), outline, 8.0)
		draw_rect(Rect2(83.0, body_top + 40.0, 38.0, 7.0), Color("667168"))
		draw_rect(Rect2(half_width - 105.0, body_top + 40.0, 38.0, 7.0), Color("667168"))

func _draw_rubble() -> void:
	var rubble := body_color.darkened(0.42)
	var half_width := _body_size.x * 0.5
	draw_polygon(
		PackedVector2Array([
			Vector2(-half_width, 35),
			Vector2(-half_width * 0.72, -7),
			Vector2(-half_width * 0.38, 18),
			Vector2(-8, -26),
			Vector2(half_width * 0.38, 3),
			Vector2(half_width * 0.68, -9),
			Vector2(half_width, 31),
		]),
		PackedColorArray([rubble])
	)
	draw_line(Vector2(-half_width * 0.55, 10), Vector2(-10, -18), Color("1d211f"), 7.0)
	draw_line(Vector2(8, -18), Vector2(half_width * 0.58, 12), Color("1d211f"), 7.0)
	draw_circle(Vector2(-half_width + 52.0, 37), 20, Color("252a27"))
	draw_circle(Vector2(half_width - 52.0, 38), 18, Color("252a27"))
	draw_rect(Rect2(-18, 7, 54, 12), Color("d4aa55", 0.52))
