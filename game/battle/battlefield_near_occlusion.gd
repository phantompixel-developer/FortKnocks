class_name BattlefieldNearOcclusion
extends Node2D

const OUTSKIRTS_FOREGROUND := "res://assets/art/production/battle/outskirts/roadblock_trial_foreground.png"
const SUBURBS_FOREGROUND := "res://assets/art/production/battle/suburbs/suburbs_foreground_painterly.png"
const OUTSKIRTS_PLATFORM := "res://assets/art/production/battle/shared/outskirts_platform_painterly.png"
const SUBURBS_PLATFORM := "res://assets/art/production/battle/suburbs/suburbs_platform_painterly.png"
const WORLD_SIZE := Vector2(2160.0, 1280.0)
const OCCLUSION_TOP := 1025.0

var _foreground: Texture2D
var _platform_texture: Texture2D
var _platform_rects: Array[Rect2] = []
var _suburbs := false

func configure_variant(variant: int) -> void:
	_suburbs = variant == 3
	var path := SUBURBS_FOREGROUND if _suburbs else OUTSKIRTS_FOREGROUND
	_foreground = load(path) as Texture2D if ResourceLoader.exists(path) else null
	path = SUBURBS_PLATFORM if _suburbs else OUTSKIRTS_PLATFORM
	_platform_texture = load(path) as Texture2D if ResourceLoader.exists(path) else null
	queue_redraw()

func configure_platforms(rects: Array[Rect2]) -> void:
	_platform_rects.clear()
	for rect in rects:
		_platform_rects.append(rect)
	queue_redraw()

func _draw() -> void:
	_draw_platform_lips()
	if _foreground == null:
		return
	var texture_size := _foreground.get_size()
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return

	# The same authored foreground also sits behind the combat objects. This
	# narrow second pass lets nearby rubble overlap only their feet and wheels.
	# Keeping it below the road contact line protects targets and the shot path.
	var source_width := minf(texture_size.x, texture_size.y * WORLD_SIZE.aspect())
	var source_x := (texture_size.x - source_width) * 0.5
	var source_top := texture_size.y * OCCLUSION_TOP / WORLD_SIZE.y
	draw_texture_rect_region(
		_foreground,
		Rect2(0.0, OCCLUSION_TOP, WORLD_SIZE.x, WORLD_SIZE.y - OCCLUSION_TOP),
		Rect2(source_x, source_top, source_width, texture_size.y - source_top),
		Color(1.0, 1.0, 1.0, 0.48)
	)

func _draw_platform_lips() -> void:
	if _platform_texture == null:
		return
	var size := _platform_texture.get_size()
	var source := (
		Rect2(0.0, 68.0, size.x, 585.0)
		if _suburbs
		else Rect2(14.0, 146.0, size.x - 28.0, 467.0)
	)
	for rect in _platform_rects:
		var lip_height := minf(20.0, rect.size.y * 0.25)
		var lip_source := Rect2(
			source.position,
			Vector2(source.size.x, source.size.y * lip_height / rect.size.y)
		)
		draw_texture_rect_region(
			_platform_texture,
			Rect2(rect.position, Vector2(rect.size.x, lip_height)),
			lip_source
		)
