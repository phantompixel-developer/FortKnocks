class_name DestructibleCover
extends StaticBody2D

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

func _ready() -> void:
	health = max_health
	_sync_body_size_from_collision()
	queue_redraw()

func configure_platform(definition: CombatPlatformDefinition) -> void:
	if definition == null:
		return

	max_health = maxi(1, definition.cover_health)
	health = max_health
	is_destroyed = false
	body_color = definition.cover_color
	_body_size = definition.cover_size
	_visual_profile = definition.visual_profile
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

	var darkening := float(stage) * 0.12
	var shell := body_color.darkened(darkening)
	var outline := Color("292c2a")
	var width := _body_size.x
	var half_width := width * 0.5
	var body_height := maxf(68.0, _body_size.y - 17.0)
	var body_top := -body_height * 0.5

	draw_rect(Rect2(-half_width, body_top, width, body_height), outline)
	draw_rect(Rect2(-half_width + 5.0, body_top + 4.0, width - 10.0, body_height - 10.0), shell)

	if _visual_profile == 1:
		_draw_sedan_cabin(shell, outline, half_width, body_top)
	elif _visual_profile == 2:
		_draw_pickup_cabin(shell, outline, half_width, body_top)
	else:
		_draw_compact_cabin(shell, outline, body_top)

	var wheel_y := body_top + body_height
	var wheel_offset := half_width - 48.0
	draw_circle(Vector2(-wheel_offset, wheel_y), 27, outline)
	draw_circle(Vector2(wheel_offset, wheel_y), 27, outline)
	draw_circle(Vector2(-wheel_offset, wheel_y), 14, Color("5d625e"))
	draw_circle(Vector2(wheel_offset, wheel_y), 14, Color("5d625e"))

	if stage >= 1:
		draw_line(Vector2(-half_width + 72.0, body_top + 10.0), Vector2(-15.0, 5.0), Color("333735"), 5.0)
		draw_line(Vector2(30.0, body_top - 25.0), Vector2(12.0, body_top - 2.0), Color("b4b9a6"), 3.0)
	if stage >= 2:
		draw_line(Vector2(half_width - 84.0, body_top + 8.0), Vector2(half_width - 34.0, wheel_y - 14.0), Color("333735"), 7.0)
		draw_line(Vector2(-half_width + 20.0, body_top + 18.0), Vector2(-half_width + 68.0, wheel_y - 12.0), Color("333735"), 6.0)
		draw_rect(Rect2(half_width - 62.0, body_top + 14.0, 48.0, 10.0), Color("343735"))

func _draw_compact_cabin(shell: Color, outline: Color, body_top: float) -> void:
	draw_polygon(
		PackedVector2Array([
			Vector2(-64, body_top),
			Vector2(-30, body_top - 42),
			Vector2(48, body_top - 42),
			Vector2(82, body_top),
		]),
		PackedColorArray([outline])
	)
	draw_polygon(
		PackedVector2Array([
			Vector2(-57, body_top - 2),
			Vector2(-25, body_top - 35),
			Vector2(42, body_top - 35),
			Vector2(72, body_top - 2),
		]),
		PackedColorArray([shell.lightened(0.06)])
	)
	draw_rect(Rect2(-18, body_top - 30, 48, 24), Color("5e716f"))

func _draw_sedan_cabin(shell: Color, outline: Color, half_width: float, body_top: float) -> void:
	draw_polygon(
		PackedVector2Array([
			Vector2(-half_width + 62.0, body_top),
			Vector2(-half_width + 105.0, body_top - 48.0),
			Vector2(half_width - 80.0, body_top - 48.0),
			Vector2(half_width - 34.0, body_top),
		]),
		PackedColorArray([outline])
	)
	draw_polygon(
		PackedVector2Array([
			Vector2(-half_width + 70.0, body_top - 3.0),
			Vector2(-half_width + 110.0, body_top - 40.0),
			Vector2(half_width - 85.0, body_top - 40.0),
			Vector2(half_width - 42.0, body_top - 3.0),
		]),
		PackedColorArray([shell.lightened(0.07)])
	)
	draw_line(Vector2(0, body_top - 40.0), Vector2(0, body_top - 4.0), Color("303634"), 5.0)
	draw_rect(Rect2(-half_width + 118.0, body_top - 34.0, 72.0, 27.0), Color("5a6c68"))
	draw_rect(Rect2(12.0, body_top - 34.0, half_width - 105.0, 27.0), Color("5a6c68"))

func _draw_pickup_cabin(shell: Color, outline: Color, half_width: float, body_top: float) -> void:
	draw_polygon(
		PackedVector2Array([
			Vector2(-half_width + 46.0, body_top),
			Vector2(-half_width + 80.0, body_top - 48.0),
			Vector2(-10.0, body_top - 48.0),
			Vector2(24.0, body_top),
		]),
		PackedColorArray([outline])
	)
	draw_polygon(
		PackedVector2Array([
			Vector2(-half_width + 54.0, body_top - 3.0),
			Vector2(-half_width + 86.0, body_top - 40.0),
			Vector2(-16.0, body_top - 40.0),
			Vector2(16.0, body_top - 3.0),
		]),
		PackedColorArray([shell.lightened(0.06)])
	)
	draw_rect(Rect2(44.0, body_top + 5.0, half_width - 54.0, 18.0), shell.darkened(0.08))

func _draw_rubble() -> void:
	var rubble := body_color.darkened(0.4)
	var half_width := _body_size.x * 0.5
	draw_polygon(
		PackedVector2Array([
			Vector2(-half_width, 35),
			Vector2(-half_width * 0.68, -5),
			Vector2(-half_width * 0.30, 18),
			Vector2(4, -22),
			Vector2(half_width * 0.46, 8),
			Vector2(half_width, 32),
		]),
		PackedColorArray([rubble])
	)
	draw_circle(Vector2(-half_width + 52.0, 37), 20, Color("303331"))
	draw_circle(Vector2(half_width - 52.0, 38), 18, Color("303331"))
