class_name ImpactEffect
extends Node2D

enum Kind {
	DUST,
	COVER,
	CREW,
	PULSE,
}

const LIFETIME := 0.62
const SPARK_DIRECTIONS := [
	Vector2(-0.96, -0.26),
	Vector2(-0.72, -0.70),
	Vector2(-0.34, -0.95),
	Vector2(0.10, -0.99),
	Vector2(0.52, -0.84),
	Vector2(0.86, -0.48),
	Vector2(0.99, -0.06),
	Vector2(0.78, 0.30),
	Vector2(0.30, 0.52),
	Vector2(-0.58, 0.42),
]

var kind := Kind.DUST
var strength := 1.0
var _age := 0.0

func setup(impact_kind: Kind, impact_strength := 1.0) -> void:
	kind = impact_kind
	strength = clampf(impact_strength, 0.55, 1.65)
	queue_redraw()

func _process(delta: float) -> void:
	_age += delta
	queue_redraw()
	if _age >= LIFETIME:
		queue_free()

func _draw() -> void:
	var progress := clampf(_age / LIFETIME, 0.0, 1.0)
	var fade := 1.0 - progress
	var base := _color_for_kind()
	var flash_fade := clampf(1.0 - progress * 3.4, 0.0, 1.0)
	var max_radius := 118.0 if kind == Kind.PULSE else 82.0
	var ring_radius := lerpf(10.0, max_radius, _ease_out(progress)) * strength

	draw_circle(Vector2.ZERO, (20.0 + 20.0 * flash_fade) * strength, Color(base.lightened(0.38), 0.75 * flash_fade))
	draw_circle(Vector2.ZERO, (8.0 + 10.0 * flash_fade) * strength, Color("f6ebcf", 0.82 * flash_fade))

	if kind == Kind.PULSE:
		draw_arc(Vector2.ZERO, ring_radius, 0.0, TAU, 40, Color(base, 0.80 * fade), maxf(2.0, 9.0 * fade), true)
		draw_arc(Vector2.ZERO, ring_radius * 0.68, 0.0, TAU, 36, Color("bce8e9", 0.54 * fade), maxf(1.0, 4.0 * fade), true)
	else:
		draw_arc(Vector2.ZERO, ring_radius, 0.0, TAU, 30, Color(base, 0.42 * fade), maxf(1.5, 5.0 * fade), true)

	for i in range(SPARK_DIRECTIONS.size()):
		var direction: Vector2 = SPARK_DIRECTIONS[i]
		var travel := (30.0 + float(i % 4) * 10.0) * strength * _ease_out(progress)
		if kind == Kind.PULSE:
			travel *= 1.45
		var start := direction * travel * 0.56
		var finish := direction * travel
		var spark_color := base.lightened(0.24)
		if kind == Kind.COVER and i % 2 == 0:
			spark_color = Color("d4aa55")
		draw_line(start, finish, Color(spark_color, fade), maxf(1.0, 5.5 * fade), true)

	match kind:
		Kind.DUST:
			_draw_dust(progress, fade)
		Kind.COVER:
			_draw_metal_debris(progress, fade)
		Kind.CREW:
			_draw_crew_hit(progress, fade)
		Kind.PULSE:
			_draw_pulse_core(progress, fade)

func _draw_dust(progress: float, fade: float) -> void:
	for i in range(7):
		var offset := Vector2(float(i - 3) * 12.0, -5.0 - float(i % 3) * 7.0)
		var radius := (10.0 + float(i % 4) * 3.0) * (0.45 + progress) * strength
		draw_circle(offset + Vector2(0.0, -35.0 * progress), radius, Color("68716a", 0.25 * fade))

func _draw_metal_debris(progress: float, fade: float) -> void:
	for i in range(6):
		var direction: Vector2 = SPARK_DIRECTIONS[(i * 2) % SPARK_DIRECTIONS.size()]
		var p := direction * (18.0 + float(i) * 7.0) * progress * strength
		draw_rect(Rect2(p - Vector2(3, 2), Vector2(7, 4)), Color("79614a", 0.70 * fade))
	for i in range(3):
		draw_circle(Vector2(float(i - 1) * 17.0, -24.0 - 22.0 * progress), 13.0 + i * 2.0, Color("545d57", 0.17 * fade))

func _draw_crew_hit(progress: float, fade: float) -> void:
	draw_arc(Vector2.ZERO, 28.0 * strength * (0.5 + progress), -2.8, -0.2, 18, Color("c85f4c", 0.55 * fade), 5.0, true)
	draw_circle(Vector2(0, -18.0 * progress), 11.0 * strength, Color("a45f42", 0.18 * fade))

func _draw_pulse_core(progress: float, fade: float) -> void:
	draw_circle(Vector2.ZERO, maxf(4.0, 34.0 * (1.0 - progress)) * strength, Color("77b6bf", 0.78 * fade))
	draw_circle(Vector2.ZERO, maxf(3.0, 17.0 * (1.0 - progress)) * strength, Color("e0f2ef", 0.76 * fade))

func _color_for_kind() -> Color:
	match kind:
		Kind.CREW:
			return Color("c85f4c")
		Kind.COVER:
			return Color("d4aa55")
		Kind.PULSE:
			return Color("77b6bf")
		_:
			return Color("a9ad9f")

func _ease_out(value: float) -> float:
	return 1.0 - pow(1.0 - value, 2.0)
