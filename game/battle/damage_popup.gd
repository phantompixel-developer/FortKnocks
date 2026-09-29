class_name DamagePopup
extends Label

const LIFETIME := 0.72

var _age := 0.0
var _start_position := Vector2.ZERO

func setup(world_position: Vector2, message: String, text_color: Color) -> void:
	global_position = world_position
	_start_position = world_position
	text = message
	modulate = text_color
	z_index = 20
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_theme_font_size_override("font_size", 25)
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	custom_minimum_size = Vector2(180.0, 40.0)
	position.x -= 90.0

func _process(delta: float) -> void:
	_age += delta
	var progress := clampf(_age / LIFETIME, 0.0, 1.0)
	global_position.y = _start_position.y - 68.0 * progress
	global_position.x = _start_position.x - 90.0
	modulate.a = 1.0 - progress
	if _age >= LIFETIME:
		queue_free()
