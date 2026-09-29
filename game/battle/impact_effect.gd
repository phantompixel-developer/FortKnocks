class_name ImpactEffect
extends Node2D

enum Kind {
	DUST,
	COVER,
	CREW,
}

const LIFETIME := 0.48
const SPARK_DIRECTIONS := [
	Vector2(-0.92, -0.38),
	Vector2(-0.55, -0.84),
	Vector2(-0.12, -0.98),
	Vector2(0.34, -0.91),
	Vector2(0.78, -0.56),
	Vector2(0.96, -0.10),
	Vector2(0.67, 0.28),
	Vector2(-0.72, 0.22),
]

var kind := Kind.DUST
var strength := 1.0
var _age := 0.0

func setup(impact_kind: Kind, impact_strength := 1.0) -> void:
	kind = impact_kind
	strength = clampf(impact_strength, 0.6, 1.4)
	queue_redraw()

func _process(delta: float) -> void:
	_age += delta
	queue_redraw()
	if _age >= LIFETIME:
		queue_free()

func _draw() -> void:
	var progress := clampf(_age / LIFETIME, 0.0, 1.0)
	var fade := 1.0 - progress
	var ring_radius := lerpf(12.0, 72.0, progress) * strength
	var base_color := _color_for_kind()

	draw_arc(Vector2.ZERO, ring_radius, 0.0, TAU, 28, Color(base_color, 0.75 * fade), maxf(2.0, 7.0 * fade), true)

	for i in range(SPARK_DIRECTIONS.size()):
		var direction: Vector2 = SPARK_DIRECTIONS[i]
		var travel := (24.0 + float(i % 3) * 9.0) * strength * progress
		var start := direction * travel * 0.45
		var finish := direction * travel
		draw_line(start, finish, Color(base_color.lightened(0.18), fade), maxf(1.0, 5.0 * fade), true)

	if kind == Kind.DUST:
		for i in range(5):
			var offset := Vector2(float(i - 2) * 13.0, -8.0 - float(i % 2) * 8.0)
			var radius := (12.0 + float(i) * 2.0) * (0.45 + progress) * strength
			draw_circle(offset + Vector2(0.0, -26.0 * progress), radius, Color("777d76", 0.26 * fade))
	else:
		draw_circle(Vector2.ZERO, maxf(2.0, 18.0 * (1.0 - progress)) * strength, Color(base_color.lightened(0.35), 0.8 * fade))

func _color_for_kind() -> Color:
	match kind:
		Kind.CREW:
			return Color("df8167")
		Kind.COVER:
			return Color("d9a35f")
		_:
			return Color("aeb09b")
