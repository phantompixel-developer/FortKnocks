class_name WorkshopHardwareDisplay
extends Control

const ProductionArtScript := preload("res://game/presentation/production_art.gd")
const WEAPONS_PATH := "res://assets/art/production/workshop/workshop_weapons.svg"
const MODULES_PATH := "res://assets/art/production/workshop/workshop_modules.svg"

@export_enum("weapons", "modules") var mode := "weapons"

var _weapons: Texture2D
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
		if _modules == null:
			_modules = ProductionArtScript.texture_from_svg(MODULES_PATH)
		if _modules != null:
			draw_texture_rect(_modules, Rect2(Vector2.ZERO, size), false)
		_draw_module_marker()
		return

	if _weapons == null:
		_weapons = ProductionArtScript.texture_from_svg(WEAPONS_PATH)
	if _weapons != null:
		draw_texture_rect(_weapons, Rect2(Vector2.ZERO, size), false)
	_draw_weapon_marker()

func _draw_weapon_marker() -> void:
	var centers := {
		"scrap_bolt": Vector2(size.x * 0.17, size.y * 0.52),
		"heavy_slug": Vector2(size.x * 0.50, size.y * 0.52),
		"shock_capsule": Vector2(size.x * 0.83, size.y * 0.52),
	}
	if _carry_both_specialists:
		for id in ["heavy_slug", "shock_capsule"]:
			var both_p: Vector2 = centers[id]
			draw_arc(both_p, 42.0, 0.0, TAU, 36, Color("e7ad3c", 0.88), 3.0, true)
			draw_circle(both_p + Vector2(31, -29), 6.0, Color("e7ad3c"))
		return
	if not centers.has(_active_specialist):
		return
	var p: Vector2 = centers[_active_specialist]
	draw_arc(p, 42.0, 0.0, TAU, 36, Color("e7ad3c", 0.88), 3.0, true)
	draw_circle(p + Vector2(31, -29), 6.0, Color("e7ad3c"))

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
	draw_arc(p, 40.0, 0.0, TAU, 36, Color("77b6bf", 0.92), 3.0, true)
	draw_circle(p + Vector2(29, -27), 6.0, Color("77b6bf"))
