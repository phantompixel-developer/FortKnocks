class_name WorkshopHardwareDisplay
extends Control

const ProductionArtScript := preload("res://game/presentation/production_art.gd")
const MODULES_PATH := "res://assets/art/production/workshop/workshop_modules.svg"
const WEAPON_PATHS := {
	"scrap_bolt": "res://assets/art/production/workshop/scrap_bolt_hero.svg",
	"heavy_slug": "res://assets/art/production/workshop/heavy_slug_hero.svg",
	"shock_capsule": "res://assets/art/production/workshop/shock_capsule_hero.svg",
}

@export_enum("weapons", "modules") var mode: String = "weapons"

var _weapon_textures: Dictionary = {}
var _modules: Texture2D
var _active_specialist := "heavy_slug"
var _carry_both_specialists := false
var _active_module := ""

func configure_specialist(id: String, carry_both := false) -> void:
	_active_specialist = id
	_carry_both_specialists = carry_both
	queue_redraw()

func configure_module(id: String) -> void:
	_active_module = id
	queue_redraw()

func _draw() -> void:
	if mode == "modules":
		_draw_modules()
		return
	_draw_weapon_bench()

func _draw_weapon_bench() -> void:
	# The reference uses one large workshop hero object rather than three tiny
	# equal thumbnails. Scrap Bolt remains visible as the permanent core round,
	# while the selected specialist owns the workbench.
	var bolt := _weapon_texture("scrap_bolt")
	if bolt != null:
		draw_texture_rect(
			bolt,
			Rect2(size.x * 0.035, size.y * 0.20, size.x * 0.30, size.y * 0.58),
			false
		)

	if _carry_both_specialists:
		var heavy := _weapon_texture("heavy_slug")
		var shock := _weapon_texture("shock_capsule")
		if heavy != null:
			draw_texture_rect(
				heavy,
				Rect2(size.x * 0.29, size.y * 0.08, size.x * 0.36, size.y * 0.78),
				false
			)
		if shock != null:
			draw_texture_rect(
				shock,
				Rect2(size.x * 0.60, size.y * 0.08, size.x * 0.36, size.y * 0.78),
				false
			)
		draw_arc(Vector2(size.x * 0.47, size.y * 0.50), 48.0, 0.0, TAU, 40, Color("e7ad3c", 0.78), 3.0, true)
		draw_arc(Vector2(size.x * 0.78, size.y * 0.50), 48.0, 0.0, TAU, 40, Color("77b6bf", 0.78), 3.0, true)
		return

	var specialist := _weapon_texture(_active_specialist)
	if specialist != null:
		var hero_rect := Rect2(size.x * 0.27, size.y * 0.02, size.x * 0.69, size.y * 0.92)
		draw_texture_rect(specialist, hero_rect, false)
		var accent := Color("77b6bf") if _active_specialist == "shock_capsule" else Color("e7ad3c")
		draw_circle(Vector2(size.x * 0.71, size.y * 0.50), minf(size.x, size.y) * 0.23, Color(accent, 0.055))
		draw_arc(
			Vector2(size.x * 0.71, size.y * 0.50),
			minf(size.x, size.y) * 0.23,
			-2.5,
			0.6,
			32,
			Color(accent, 0.72),
			3.0,
			true
		)

func _draw_modules() -> void:
	if _modules == null:
		_modules = ProductionArtScript.texture_from_svg(MODULES_PATH)
	if _modules != null:
		draw_texture_rect(_modules, Rect2(Vector2.ZERO, size), false)
	_draw_module_marker()

func _weapon_texture(id: String) -> Texture2D:
	if _weapon_textures.has(id):
		return _weapon_textures[id] as Texture2D
	if not WEAPON_PATHS.has(id):
		return null
	var texture: Texture2D = ProductionArtScript.texture_from_svg(str(WEAPON_PATHS[id]))
	_weapon_textures[id] = texture
	return texture

func _draw_module_marker() -> void:
	var centers := {
		"spotter_rack": Vector2(size.x * 0.12, size.y * 0.50),
		"ballast_crates": Vector2(size.x * 0.35, size.y * 0.53),
		"twin_field_rack": Vector2(size.x * 0.64, size.y * 0.50),
		"stabilizer_rig": Vector2(size.x * 0.88, size.y * 0.53),
	}
	if _active_module.is_empty() or not centers.has(_active_module):
		return
	var p: Vector2 = centers[_active_module]
	draw_circle(p, 44.0, Color("77b6bf", 0.055))
	draw_arc(p, 42.0, 0.0, TAU, 36, Color("77b6bf", 0.92), 3.0, true)
	draw_circle(p + Vector2(29, -27), 6.0, Color("77b6bf"))
